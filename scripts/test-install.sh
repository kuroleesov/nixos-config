#!/usr/bin/env bash
# Самопроверка install.sh на фейковом sysfs, настоящее железо не нужно
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
COPY="$TMP/repo"
BIN="$TMP/bin"
mkdir -p "$COPY" "$BIN"

# .git не копируем: в worktree это файл-ссылка на настоящий репозиторий
tar -C "$SRC" --exclude=.claude --exclude='result*' --exclude=.git -cf - . | tar -C "$COPY" -xf -
git -C "$COPY" init -q
git -C "$COPY" add -A

stub() { printf '#!/usr/bin/env bash\n%s\n' "$2" >"$BIN/$1"; chmod +x "$BIN/$1"; }
stub nixos-generate-config 'cat <<NIX
{ lib, ... }:
{
  fileSystems."/" = { device = "/dev/disk/by-label/nixos"; fsType = "ext4"; };
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
NIX'
# shellcheck disable=SC2016  # переменные должны раскрываться в самой заглушке
stub systemd-detect-virt '[ -n "${FAKE_VIRT:-}" ] && { echo "$FAKE_VIRT"; exit 0; }; echo none; exit 1'
stub nixos-version 'echo "26.05.20261113.d5cc683 (Zokor)"'
# корень: btrfs-подтом на LUKS на разделе
stub findmnt 'echo "/dev/mapper/root[/@]"'
stub lsblk 'printf "/dev/mapper/root crypt\n/dev/sda2 part\n/dev/sda disk\n"'
# применение в тесте запрещено: если скрипт до него дойдёт, тест упадёт, а система не изменится
for cmd in nixos-rebuild nixos-install nixos-enter passwd; do stub "$cmd" 'echo "STUB: применение в тесте" >&2; exit 99'; done
# sudo пропускает только определение железа
# shellcheck disable=SC2016  # переменные должны раскрываться в самой заглушке
stub sudo '[ "$1" = nixos-generate-config ] && exec "$@"; echo "STUB: sudo $* в тесте" >&2; exit 99'
export PATH="$BIN:$PATH"
# пустой /etc/nixos: stateVersion берётся из nixos-version
export ETC_NIXOS="$TMP/etc-nixos"
mkdir -p "$ETC_NIXOS"

# fake_sys DIR UEFI BATTERY BT "адрес класс вендор девайс"...
fake_sys() {
  local d="$1" uefi="$2" bat="$3" bt="$4" e addr class vendor dev
  shift 4
  mkdir -p "$d/bus/pci/devices" "$d/class/power_supply" "$d/class/bluetooth"
  if [ "$uefi" = 1 ]; then mkdir -p "$d/firmware/efi"; fi
  if [ "$bat" = 1 ]; then
    mkdir -p "$d/class/power_supply/BAT0"
    echo Battery >"$d/class/power_supply/BAT0/type"
  fi
  if [ "$bt" = 1 ]; then mkdir -p "$d/class/bluetooth/hci0"; fi
  for e in "$@"; do
    read -r addr class vendor dev <<<"$e"
    mkdir -p "$d/bus/pci/devices/$addr"
    echo "$class" >"$d/bus/pci/devices/$addr/class"
    echo "$vendor" >"$d/bus/pci/devices/$addr/vendor"
    echo "$dev" >"$d/bus/pci/devices/$addr/device"
  done
}

FAIL=0
# check КЕЙС ФАЙЛ шаблон...: шаблон с ! в начале должен отсутствовать
check() {
  local name="$1" file="$2" p
  shift 2
  for p in "$@"; do
    if [ "${p:0:1}" = "!" ]; then
      if grep -qF -- "${p:1}" "$file"; then echo "FAIL $name: лишнее '${p:1}'"; FAIL=1; fi
    elif ! grep -qF -- "$p" "$file"; then
      echo "FAIL $name: нет '$p'"; FAIL=1
    fi
  done
}

# run_case ИМЯ UEFI BATTERY BT VIRT шаблоны... -- записи gpu...
run_case() {
  local name="$1" uefi="$2" bat="$3" bt="$4" virt="$5" before=$FAIL
  local pats=()
  shift 5
  while [ "$1" != "--" ]; do pats+=("$1"); shift; done
  shift
  fake_sys "$TMP/sys-$name" "$uefi" "$bat" "$bt" "$@"
  (cd "$COPY" && FAKE_VIRT="$virt" SYSFS="$TMP/sys-$name" ./install.sh --host "t-$name" --user tester --no-apply --yes >/dev/null) \
    || { echo "FAIL $name: install.sh упал"; FAIL=1; }
  check "$name" "$COPY/hosts/t-$name/default.nix" "${pats[@]}"
  if [ "${SKIP_EVAL:-0}" != 1 ]; then
    nix eval --raw "$COPY#nixosConfigurations.t-$name.config.system.build.toplevel.drvPath" >/dev/null \
      || { echo "FAIL $name: eval"; FAIL=1; }
  fi
  if [ "$FAIL" = "$before" ]; then echo "PASS $name"; fi
}

run_case nvidia-desktop 1 0 1 "" 'hardware/nvidia.nix' 'systemd-boot.enable' 'bluetooth.enable' 'stateVersion = "26.05"' '!open = false' '!prime' -- \
  "0000:01:00.0 0x030000 0x10de 0x2882"
run_case nvidia-igpu-desktop 1 0 0 "" 'hardware/nvidia.nix' '!hardware/intel.nix' '!prime' -- \
  "0000:00:02.0 0x030000 0x8086 0x4680" "0000:01:00.0 0x030000 0x10de 0x2882"
run_case hybrid-laptop 1 1 0 "" 'hardware/nvidia.nix' 'hardware/intel.nix' 'intelBusId = "PCI:0:2:0"' 'nvidiaBusId = "PCI:1:0:0"' 'finegrained' -- \
  "0000:00:02.0 0x030000 0x8086 0x46a6" "0000:01:00.0 0x030200 0x10de 0x25a2"
run_case old-nvidia-bios 0 0 0 "" 'open = false' 'nvidiaPackages.legacy_580' 'grub.device = "/dev/sda"' -- \
  "0000:01:00.0 0x030000 0x10de 0x1b80"
run_case amd-desktop 1 0 0 "" 'hardware/amd.nix' -- \
  "0000:03:00.0 0x030000 0x1002 0x73bf"
run_case amd-igpu-desktop 1 0 0 "" 'hardware/amd.nix' '!hardware/intel.nix' -- \
  "0000:00:02.0 0x030000 0x8086 0x4680" "0000:03:00.0 0x030000 0x1002 0x73bf"
run_case qemu-vm 1 0 0 kvm 'qemuGuest.enable' '!hardware/' -- \
  "0000:00:01.0 0x030000 0x1af4 0x1111"

# уже установленная NixOS: stateVersion из старого /etc/nixos/configuration.nix
echo '{ system.stateVersion = "24.11"; }' >"$ETC_NIXOS/configuration.nix"
run_case old-install 1 0 0 "" 'stateVersion = "24.11"' -- "0000:03:00.0 0x030000 0x1002 0x73bf"
rm "$ETC_NIXOS/configuration.nix"

# --dry-run для существующего хоста: выходит сразу; дойди он до применения, заглушки вернули бы 99
if OUT="$(cd "$COPY" && SYSFS="$TMP/sys-amd-desktop" ./install.sh --host t-amd-desktop --user tester --dry-run 2>&1)" \
  && grep -qF 'уже существует' <<<"$OUT"; then
  echo "PASS dry-run-existing"
else
  echo "FAIL dry-run-existing"; FAIL=1
fi

# --root для существующего хоста: hardware-configuration.nix пересоздаётся под новые диски
echo '{ }' >"$COPY/hosts/t-amd-desktop/hardware-configuration.nix"
if (cd "$COPY" && SYSFS="$TMP/sys-amd-desktop" ./install.sh --host t-amd-desktop --user tester --root "$TMP/mnt" --no-apply --yes >/dev/null) \
  && grep -qF 'fileSystems' "$COPY/hosts/t-amd-desktop/hardware-configuration.nix"; then
  echo "PASS root-existing"
else
  echo "FAIL root-existing"; FAIL=1
fi

# --dry-run: печатает конфиг и ничего не создаёт
fake_sys "$TMP/sys-dry" 1 0 0
# вывод сначала в переменную: grep -q в пайпе обрывает его, и pipefail считает это ошибкой
DRY_OUT="$(cd "$COPY" && SYSFS="$TMP/sys-dry" ./install.sh --host t-dry --user tester --dry-run)" || DRY_OUT=""
if grep -qF 'networking.hostName' <<<"$DRY_OUT" && [ ! -e "$COPY/hosts/t-dry" ]; then
  echo "PASS dry-run"
else
  echo "FAIL dry-run"; FAIL=1
fi

exit "$FAIL"
