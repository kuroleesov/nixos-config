#!/usr/bin/env bash
# Установка на любой компьютер с NixOS: определяет железо, создаёт hosts/<имя>/ и применяет конфиг
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# тесты подставляют фейковые каталоги
SYSFS="${SYSFS:-/sys}"
ETC_NIXOS="${ETC_NIXOS:-/etc/nixos}"
SUDO=""
[ "$EUID" -eq 0 ] || SUDO="sudo"

die() { echo "Ошибка: $*" >&2; exit 1; }

usage() {
  cat <<USAGE
Использование: ./install.sh [--host ИМЯ] [--user ИМЯ] [--root DIR] [--no-apply] [--dry-run] [--yes]
  --host ИМЯ   имя хоста (по умолчанию hostname)
  --user ИМЯ   пользователь (по умолчанию текущий)
  --root DIR   ставить в смонтированную систему (nixos-install)
  --no-apply   только создать hosts/<имя>, не применять
  --dry-run    показать, что будет создано, ничего не писать
  --yes        без подтверждения
USAGE
}

HOST="" USER_NAME="" ROOT="" NO_APPLY=0 DRY=0 YES=0
ARGS=("$@")
while [ $# -gt 0 ]; do
  case "$1" in
    --host) HOST="${2:?}"; shift 2 ;;
    --user) USER_NAME="${2:?}"; shift 2 ;;
    --root) ROOT="${2:?}"; shift 2 ;;
    --no-apply) NO_APPLY=1; shift ;;
    --dry-run) DRY=1; shift ;;
    --yes) YES=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; die "неизвестный аргумент: $1" ;;
  esac
done

[ -e /etc/NIXOS ] || die "скрипт работает только на NixOS"
# от root файлы в репозитории пользователя стали бы чужими; sudo скрипт вызывает сам. С --root (live-образ) можно
[ "$EUID" -ne 0 ] || [ -n "$ROOT" ] || die "запусти без sudo: права root скрипт попросит сам"

# git нужен flake; если его нет, перезапускаемся внутри nix-shell
if ! command -v git >/dev/null; then
  exec nix-shell -p git --run "$(printf '%q ' "$0" "${ARGS[@]}")"
fi

# ---------- определение железа ----------
GPUS=() # vendor:device:адрес
for d in "$SYSFS"/bus/pci/devices/*; do
  [ -e "$d/class" ] || continue
  [[ "$(cat "$d/class")" == 0x03* ]] || continue
  case "$(cat "$d/vendor")" in
    0x10de) v=nvidia ;;
    0x1002) v=amd ;;
    0x8086) v=intel ;;
    *) continue ;;
  esac
  GPUS+=("$v:$(cat "$d/device"):$(basename "$d")")
done

FW=bios
[ -d "$SYSFS/firmware/efi" ] && FW=uefi

LAPTOP=0
for f in "$SYSFS"/class/power_supply/*/type; do
  if [ -e "$f" ] && [ "$(cat "$f")" = "Battery" ]; then LAPTOP=1; fi
done

BT=0
for f in "$SYSFS"/class/bluetooth/hci*; do
  if [ -e "$f" ]; then BT=1; fi
done

VIRT="$(systemd-detect-virt 2>/dev/null || true)"
[ -n "$VIRT" ] || VIRT=none

# stateVersion — версия первой установки: на уже установленной NixOS берём её из старого конфига, иначе текущая
STATE_VERSION=""
if [ -f "$ROOT$ETC_NIXOS/configuration.nix" ]; then
  STATE_VERSION="$(grep -oE 'system\.stateVersion *= *"[0-9]+\.[0-9]+"' "$ROOT$ETC_NIXOS/configuration.nix" | grep -oE '[0-9]+\.[0-9]+' | head -n1 || true)"
fi
[ -n "$STATE_VERSION" ] || STATE_VERSION="$(nixos-version | grep -oE '[0-9]{2}\.[0-9]{2}' | head -n1)"
[ -n "$STATE_VERSION" ] || die "не удалось определить версию NixOS"

# ---------- хост и пользователь ----------
DEF_USER="${SUDO_USER:-${USER:-}}"
case "$DEF_USER" in root|nixos) DEF_USER="" ;; esac
ask() { # ask ПЕРЕМЕННАЯ "вопрос" ПО_УМОЛЧАНИЮ: флаг важнее вопроса, Enter берёт значение по умолчанию
  local ans=""
  [ -z "${!1}" ] || return 0
  if [ -t 0 ] && [ "$YES" != 1 ]; then read -rp "$2${3:+ [$3]}: " ans; fi
  printf -v "$1" '%s' "${ans:-$3}"
  [ -n "${!1}" ] || die "не задано значение: $2 (передайте флагом)"
}
ask HOST "Имя хоста" "$(hostname)"
ask USER_NAME "Имя пользователя" "$DEF_USER"
[[ "$HOST" =~ ^[a-z0-9][a-z0-9-]*$ ]] || die "некорректное имя хоста: $HOST"
[[ "$USER_NAME" =~ ^[a-z_][a-z0-9_-]*$ ]] || die "некорректное имя пользователя: $USER_NAME"

# ---------- генерация hosts/<имя> ----------
HOSTDIR="$REPO/hosts/$HOST"

summary() {
  local s="${FW^^}, GPU:" g
  for g in "${GPUS[@]}"; do s+=" ${g%%:*}"; done
  [ "${#GPUS[@]}" -gt 0 ] || s+=" нет"
  if [ "$LAPTOP" = 1 ]; then s+=", ноутбук"; else s+=", ПК"; fi
  if [ "$BT" = 1 ]; then s+=", bluetooth"; fi
  if [ "$VIRT" != none ]; then s+=", VM: $VIRT"; fi
  echo "$s"
}

# "0000:01:00.0" -> "PCI:1:0:0" (hex -> decimal)
# shortcut: домен PCI игнорируется, нужен только для редких многодоменных систем
busid() {
  local a="${1#*:}" # bb:dd.f
  local b="${a%%:*}" rest="${a#*:}"
  echo "PCI:$((16#$b)):$((16#${rest%%.*})):$((16#${rest##*.}))"
}

gen_default() {
  local nvdev="" nvaddr="" other="" otherbus="" g v rest has_intel=0 has_amd=0
  for g in "${GPUS[@]}"; do
    v="${g%%:*}" rest="${g#*:}"
    case "$v" in
      nvidia) if [ -z "$nvaddr" ]; then nvdev="${rest%%:*}"; nvaddr="${rest#*:}"; fi ;;
      intel) has_intel=1 ;;
      amd) has_amd=1 ;;
    esac
    if [ "$v" != nvidia ] && [ -z "$other" ]; then other="$v"; otherbus="${rest#*:}"; fi
  done
  # shortcut: порог Turing по device id (>= 0x1e00), редкие исключения не учтены; пересмотреть при новых архитектурах
  local turing=0
  if [ -n "$nvaddr" ] && [ $((nvdev)) -ge $((0x1e00)) ]; then turing=1; fi
  # ноутбук с NVIDIA и встроенной: PRIME offload, подключаем обе. На ПК — только одну, дискретную
  # (NVIDIA > AMD > Intel): мониторы обычно в ней, а модули разных карт спорят о LIBVA_DRIVER_NAME
  local hybrid=0
  if [ -n "$nvaddr" ] && [ -n "$other" ] && [ "$LAPTOP" = 1 ]; then hybrid=1; fi
  if [ -n "$nvaddr" ] && [ "$hybrid" = 0 ]; then
    has_intel=0 has_amd=0
  elif [ "$LAPTOP" = 0 ] && [ "$has_amd" = 1 ]; then
    has_intel=0
  fi

  echo "# $HOST: создано install.sh — $(summary)"
  echo "{ config, lib, ... }:"
  echo "{"
  echo "  imports = ["
  echo "    ./hardware-configuration.nix"
  echo "    ../../system"
  if [ -n "$nvaddr" ]; then echo "    ../../system/hardware/nvidia.nix"; fi
  if [ "$has_intel" = 1 ]; then echo "    ../../system/hardware/intel.nix"; fi
  if [ "$has_amd" = 1 ]; then echo "    ../../system/hardware/amd.nix"; fi
  echo "  ];"
  echo
  if [ "$FW" = uefi ]; then
    cat <<'NIX'
  # загрузчик UEFI
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;
NIX
  else
    local src disk
    src="$(findmnt -no SOURCE "${ROOT:-/}" || true)"
    src="${src%%\[*}" # btrfs-подтом выглядит как /dev/sda2[/@]
    # вверх по цепочке (LUKS, LVM, раздел) до физического диска
    disk="$(lsblk -nlpso NAME,TYPE "$src" 2>/dev/null | awk '$2 == "disk" && !d { d = $1 } END { print d }' || true)"
    [ -n "$disk" ] || die "не удалось найти диск для GRUB"
    cat <<NIX
  # загрузчик BIOS: GRUB на диск с корневой ФС
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "$disk";
NIX
  fi
  echo
  echo "  networking.hostName = \"$HOST\";"
  if [ "$BT" = 1 ]; then
    cat <<'NIX'

  # bluetooth найден в системе
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
NIX
  fi
  if [ -n "$nvaddr" ] && [ "$turing" = 0 ]; then
    cat <<'NIX'

  # карта старше Turing: открытых модулей ядра нет, а stable (595+) уже не поддерживает Maxwell/Pascal/Volta.
  # Kepler и старше нужен legacy_470 (может не собраться со свежим ядром)
  hardware.nvidia.open = false;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
NIX
  fi
  if [ "$hybrid" = 1 ]; then
    local key=intelBusId
    if [ "$other" = amd ]; then key=amdgpuBusId; fi
    cat <<NIX

  # гибридная графика: NVIDIA включается по запросу (nvidia-offload)
  hardware.nvidia.prime = {
    offload.enable = true;
    offload.enableOffloadCmd = true;
    $key = "$(busid "$otherbus")";
    nvidiaBusId = "$(busid "$nvaddr")";
  };
NIX
    if [ "$turing" = 1 ]; then
      cat <<'NIX'
  # карта засыпает, когда не нужна (экономия батареи)
  hardware.nvidia.powerManagement.finegrained = true;
NIX
    fi
  fi
  case "$VIRT" in
    kvm|qemu) cat <<'NIX'

  # гостевые утилиты QEMU/KVM
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;
NIX
      ;;
    oracle) cat <<'NIX'

  # гость VirtualBox; хост-режим из system/apps.nix отключаем
  virtualisation.virtualbox.guest.enable = true;
  virtualisation.virtualbox.host.enable = lib.mkForce false;
NIX
      ;;
    vmware) cat <<'NIX'

  # гостевые утилиты VMware
  virtualisation.vmware.guest.enable = true;
NIX
      ;;
  esac
  echo
  echo "  system.stateVersion = \"$STATE_VERSION\"; # Не менять: версия NixOS при установке"
  echo "}"
}

gen_meta() { echo "{ user = \"$USER_NAME\"; }"; }

if [ -d "$HOSTDIR" ]; then
  echo "hosts/$HOST уже существует, оставляю как есть."
  [ "$DRY" != 1 ] || exit 0
  # установка с live-образа = новые диски: старые UUID в hardware-configuration.nix не загрузятся
  if [ -n "$ROOT" ]; then
    echo "Обновляю hosts/$HOST/hardware-configuration.nix под диски в $ROOT."
    hw="$($SUDO nixos-generate-config --show-hardware-config --root "$ROOT")"
    printf '%s\n' "$hw" >"$HOSTDIR/hardware-configuration.nix"
  fi
else
  echo "Найдено: $(summary)"
  if [ "$DRY" = 1 ]; then
    echo "--- hosts/$HOST/default.nix ---"
    gen_default
    echo "--- hosts/$HOST/meta.nix ---"
    gen_meta
    exit 0
  fi
  if [ "$YES" != 1 ]; then
    [ -t 0 ] || die "нужно подтверждение: запустите с --yes"
    read -rp "Создать hosts/$HOST для пользователя $USER_NAME? [y/N] " ans
    [[ "$ans" =~ ^[yY] ]] || die "отменено"
  fi
  # собираем во временной папке: при ошибке не останется недописанного hosts/<имя>, который повторный запуск принял бы за готовый
  TMPDIR_HOST="$(mktemp -d)"
  trap 'rm -rf "$TMPDIR_HOST"' EXIT
  gen_default >"$TMPDIR_HOST/default.nix"
  gen_meta >"$TMPDIR_HOST/meta.nix"
  hwargs=(--show-hardware-config)
  [ -z "$ROOT" ] || hwargs+=(--root "$ROOT")
  $SUDO nixos-generate-config "${hwargs[@]}" >"$TMPDIR_HOST/hardware-configuration.nix"
  chmod 755 "$TMPDIR_HOST"
  mkdir -p "$REPO/hosts"
  mv "$TMPDIR_HOST" "$HOSTDIR"
fi

# flake видит только файлы под git; safe.directory — если скрипт запущен от root, а репозиторий пользователя
git -c safe.directory="$REPO" -C "$REPO" add "hosts/$HOST"

# ---------- применение ----------
if [ -n "$ROOT" ]; then
  APPLY=(nixos-install --root "$ROOT" --flake "$REPO#$HOST")
else
  APPLY=(nixos-rebuild switch --flake "$REPO#$HOST")
fi
if [ "$NO_APPLY" = 1 ]; then
  echo "Конфиг создан. Применить: $SUDO env NIX_CONFIG='experimental-features = nix-command flakes' ${APPLY[*]}"
  exit 0
fi
$SUDO env NIX_CONFIG="experimental-features = nix-command flakes" "${APPLY[@]}"

# репозиторий должен лежать в ~/nixos-config (алиасы, nh и симлинки Hyprland ждут этот путь)
TARGET="$ROOT/home/$USER_NAME/nixos-config"
if [ ! -e "$TARGET" ] && [ "$REPO" != "$TARGET" ]; then
  $SUDO mkdir -p "$(dirname "$TARGET")"
  $SUDO cp -a "$REPO" "$TARGET"
  if [ -n "$ROOT" ]; then
    $SUDO nixos-enter --root "$ROOT" -c "chown -R $USER_NAME: /home/$USER_NAME/nixos-config"
  else
    $SUDO chown -R "$USER_NAME:" "$TARGET"
  fi
elif [ -e "$TARGET" ] && [ "$(realpath "$TARGET")" != "$(realpath "$REPO")" ]; then
  echo "Предупреждение: $TARGET уже занят другим каталогом, не трогаю. Перенеси $REPO туда, иначе rebuild возьмёт не тот конфиг." >&2
  TARGET="$REPO"
fi

# пароль: на новой установке его нет, на установленной системе — если не задан или заблокирован
if [ -n "$ROOT" ]; then
  PASSWD=(nixos-enter --root "$ROOT" -c "passwd $USER_NAME")
elif [[ "$($SUDO passwd -S "$USER_NAME" 2>/dev/null | awk '{print $2}')" =~ ^(NP|L)$ ]]; then
  PASSWD=(passwd "$USER_NAME")
else
  PASSWD=()
fi
if [ "${#PASSWD[@]}" -gt 0 ]; then
  # без терминала passwd упал бы уже после успешной установки
  if [ -t 0 ]; then $SUDO "${PASSWD[@]}"; else echo "Задай пароль пользователю $USER_NAME: $SUDO ${PASSWD[*]}" >&2; fi
fi

echo "Готово: система $HOST применена, репозиторий в $TARGET."
echo "Дальше пересобирать просто командой: rebuild (nh os switch)."
