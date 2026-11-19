# nixos-config

NixOS + Home Manager: Hyprland, Noctalia Shell, fish. Один flake на все компьютеры: общая часть в `system/` и `home/`, железо каждого компьютера в `hosts/<имя>/`.

## Установка на новый компьютер

Нужна NixOS: уже установленная (любой вариант с экрана установщика) или live-образ.

```bash
nix-shell -p git
git clone <адрес-репозитория> ~/nixos-config
cd ~/nixos-config
./install.sh
```

С live-образа сначала разметь диски и смонтируй их в `/mnt`, затем `./install.sh --root /mnt`.

`install.sh` смотрит, что за компьютер, и создаёт под него `hosts/<имя>/`:

- видеокарта: NVIDIA, AMD или Intel → `system/hardware/<nvidia|amd|intel>.nix`; для NVIDIA старше Turing (до RTX 20xx / GTX 16xx) выключает открытые модули; ноутбук с NVIDIA и встроенной → PRIME offload (`nvidia-offload <программа>`), ПК с NVIDIA → только NVIDIA;
- UEFI → systemd-boot, BIOS → GRUB на физический диск с корнем (в том числе через LUKS/LVM/btrfs);
- Bluetooth; виртуальная машина (QEMU/KVM, VirtualBox, VMware) → гостевые драйверы;
- `hardware-configuration.nix` из `nixos-generate-config`; `system.stateVersion` — версия первой установки (из старого `/etc/nixos/configuration.nix`, иначе текущая).

Потом применяет конфиг, кладёт репозиторий в `/home/<пользователь>/nixos-config` и задаёт пароль пользователю (при установке с live-образа всегда, на установленной системе — если пароля нет). Если `hosts/<имя>/` уже есть, скрипт не трогает его `default.nix` и `meta.nix` и только применяет; с `--root` (новые диски) пересоздаёт в нём `hardware-configuration.nix`.

Флаги: `--host <имя>`, `--user <имя>`, `--root /mnt`, `--dry-run` (только показать, что будет создано), `--no-apply` (создать файлы, не применять), `--yes` (без вопросов). Проверка скрипта на фейковом железе: `scripts/test-install.sh`.

## Где что лежит

| Путь | Что там |
|---|---|
| `flake.nix` | входы (nixpkgs, home-manager, …) и сборка всех хостов из `hosts/` |
| `hosts/pc-1/` | этот ПК: загрузчик, второй монитор, диски (`disks.nix`), `meta.nix` с именем пользователя |
| `system/` | NixOS для всех компьютеров (от root) |
| `system/nix.nix` | настройки nix, оверлеи, nh, nix-ld |
| `system/boot.nix` | ядро, bootvine, экран входа ly |
| `system/desktop.nix` | Hyprland, Plasma про запас, порталы, Thunar, печать |
| `system/fonts.nix` | шрифты |
| `system/audio.nix` | PipeWire |
| `system/network.nix` | сеть, файрвол, avahi/UxPlay, Throne |
| `system/games.nix` | Steam, GameMode |
| `system/apps.nix` | Firefox, Claude Desktop, Flatpak, VirtualBox, LocalSend |
| `system/packages.nix` | системные пакеты списком |
| `system/locale.nix`, `users.nix`, `shell.nix` | время и язык, пользователь, fish для root |
| `system/hardware/` | драйверы видеокарт, подключаются из `hosts/<имя>/` |
| `home/` | Home Manager: всё в домашней папке |
| `home/shell/` | fish, алиасы (`aliases.nix`), starship, git, CLI-утилиты |
| `home/desktop/` | Hyprland (`hypr/*.lua`), Noctalia (`noctalia/`), тема GTK/Qt/курсор, Nemo |
| `home/terminals.nix` | kitty и alacritty |
| `home/editors.nix` | Zed |
| `home/browsers/` | LibreWolf, Chromium |
| `home/apps.nix`, `media.nix`, `games.nix`, `cli.nix` | программы по темам |
| `pkgs/` | свои пакеты (il2cpp-inspector-redux) |
| `assets/` | обои и анимация ly |
| `scripts/update.sh` | обновить входы, проверить и пересобрать |

## Частые задачи

- **Применить изменения:** `rebuild`. Проверить без записи в загрузчик: `rbt`. Обновить всё: `upd`. Что поменялось: `ndiff`.
- **Добавить программу:** без настроек — строкой в `system/packages.nix` (для всех пользователей) или в `home.packages` подходящего файла `home/`; с настройками — блок `programs.<имя>` в файле по теме.
- **Хоткеи и окна Hyprland:** `home/desktop/hypr/config/keybinds.lua` и `rules.lua`. Эти файлы подключены симлинками, применяются сразу через `hr` (hyprctl reload), без пересборки.
- **Алиасы:** `home/shell/aliases.nix`, общие для fish и bash.
- **Панель, тема, обои:** `home/desktop/noctalia/`.
- **Открыть конфиг:** `nconf` (редактор), `ncode` (VS Code), `hconf` (hyprland.lua), `dt` (перейти в папку).
