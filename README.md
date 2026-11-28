# NixOS Configuration
>**Warning** These dotfiles were mostly vibecoded, so be careful.

My NixOS flake: Hyprland with the Noctalia shell, Fish, Home Manager. It's built for my own machines, so read through it before running it on yours.

The guide assumes NixOS is already installed and working. It replaces system packages and settings, so back up anything you care about first.

## Requirements

- x86_64 (Intel or AMD). ARM is not supported.
- 8 GB of RAM or more.
- Around 100 GB of free disk space. The package set includes Steam and DaVinci Resolve.
- The first build downloads over 10 GB and compiles some packages locally. Plan for an hour or two.

## Installation

```bash
nix-shell -p git
git clone https://github.com/kuroleesov/nixos-config.git ~/nixos-config
cd ~/nixos-config
./install.sh
```

Run `install.sh` as your normal user, without `sudo`. It calls `sudo` itself when it needs to. It asks for:

| Prompt | Answer |
|---|---|
| `Hostname [...]` | Lowercase letters, digits and hyphens, e.g. `workstation` |
| `Username [...]` | Your existing NixOS user. The default is the current user. |
| `Create hosts/... for user ...? [y/N]` | `y` |
| `[sudo] password` | Your password. It may be asked more than once during the build. |

When it finishes, reboot.

## First login

The login screen is ly, and the default session is Hyprland (UWSM). If Hyprland doesn't start, pick Plasma in the session list.

### Keybindings

`Super` is the Windows key.

| Keys | Action |
|---|---|
| `Super + Enter`, `Super + Q` | Terminal (Kitty) |
| `Super + Space`, `Super + D` | App launcher |
| `Super + B` / `Super + E` | Browser / file manager |
| `Super + M` | btop |
| `Super + C` | Close window |
| `Super + F` | Fullscreen |
| `Super + V` | Toggle floating |
| `Super + 1` … `Super + 0` | Go to workspace 1-10 |
| `Super + Shift + 1` … `0` | Move window to workspace |
| `Super + arrows` | Focus window |
| `Super + Shift + arrows` | Move window |
| `Super + Ctrl + arrows` | Resize window |
| `Super + S` / `Super + Shift + S` | Show / move window to the scratchpad workspace |
| `Super + Tab` | Window switcher |
| `Super + A` | Control center (audio, network, Bluetooth) |
| `Super + N` | Notifications |
| `Super + Shift + V` | Clipboard history |
| `Super + W` | Wallpapers |
| `Super + ,` | Noctalia settings |
| `Super + L` | Lock |
| `Super + X` | Power menu |
| `Super + Shift + E` | Quit Hyprland |
| `Print` / `Ctrl + Print` | Screenshot of a region / the whole screen |
| `Shift + Print` | Region screenshot opened in Satty |
| `Alt + Shift` | Switch layout (US / RU) |

All bindings are in `home/desktop/hypr/config/keybinds.lua`.

## Shell aliases

| Alias | Runs |
|---|---|
| `rebuild` | `nh os switch`: build and apply |
| `rbt` | `nh os test`: apply without adding a boot entry |
| `upd` | `nh os switch --update`: update `flake.lock`, then apply |
| `ndiff` | Package diff between the last two generations |
| `nclean` | Delete old generations (keeps 5 and anything from the last 7 days) |
| `dt` | `cd` into the repo |
| `nconf` / `ncode` | Open the repo in Neovim / VS Code |
| `hconf` | Open `hyprland.lua` in Neovim |
| `hr` | `hyprctl reload` |

If a `rebuild` breaks the system, reboot and pick the previous generation in the boot menu.

## Things you'll probably want to change

- Timezone and locale: `system/locale.nix`. Currently Europe/Moscow, English UI, Russian formats for dates, numbers and units.
- System packages: `system/packages.nix`. Drop whatever you don't use (Discord, Spotify, DaVinci Resolve, ...).
- User apps: `home/apps.nix`, `home/media.nix`, `home/games.nix` (osu!, Steam Guard), `home/editors.nix` (Zed).
- Hyprland: anything under `home/desktop/hypr/`. These files are symlinked, so `hr` picks up changes without a rebuild.
- Personal data goes in `private/`, which is gitignored. Fish sources `private/*.fish`, Git includes `private/gitconfig`, and Noctalia reads the weather/night light location from `private/noctalia.toml`:

  ```toml
  [location]
  address = "City"
  latitude = 55.75
  longitude = 37.62
  ```

  Missing files are skipped. Copy the folder by hand when moving to another machine.

To install something, add it to `system/packages.nix` (system-wide) or to a `home.packages` list under `home/` (per user). If NixOS or Home Manager has a `programs.<name>` module for it, use that instead.

## Troubleshooting

`this script only works on NixOS`: install NixOS first. This repo doesn't do the base install.

`run without sudo`: start it as `./install.sh`.

`invalid hostname`: no uppercase, spaces or underscores.

The install got interrupted: run `./install.sh` again. It reuses the existing `hosts/<hostname>/`.

Black screen after reboot: usually NVIDIA. Boot the previous generation, or log into Plasma.

GTX 600/700 or older: the installer picks `legacy_580` for pre-Turing cards, but Kepler needs `legacy_470`. Change it in `hosts/<hostname>/default.nix` and run `rebuild`. It may not build with a recent kernel.

Virtual machine: Hyprland needs 3D acceleration enabled in the VM settings. Use Plasma if it still fails.

`error while loading shared libraries: libXXX.so` from a downloaded binary: find the package with `nix-locate libXXX.so`, add it to `programs.nix-ld.libraries` in `system/compat.nix`, rebuild and log in again.

AppImages: right-click in Nemo and choose "Добавить в меню приложений" to get a menu entry. The file stays where it is. From a terminal, run `appimage-run <file>`.

## How install.sh works

It inspects the hardware and writes `hosts/<hostname>/`:

- GPU: imports `system/hardware/{nvidia,amd,intel}.nix`. NVIDIA cards older than Turing get the proprietary `legacy_580` driver instead of the open modules. Laptops with NVIDIA plus an iGPU get PRIME offload (`nvidia-offload <program>`); desktops use only the discrete card.
- Bootloader: systemd-boot on UEFI, GRUB on BIOS, installed to the disk that holds `/` (resolved through LUKS/LVM/btrfs).
- Bluetooth is enabled if an adapter is found.
- Guest tools for QEMU/KVM, VirtualBox or VMware when running in a VM.
- `hardware-configuration.nix` comes from `nixos-generate-config`. `system.stateVersion` is taken from `/etc/nixos/configuration.nix` if it exists, otherwise the current release.

Then it applies the config, copies the repo to `/home/<user>/nixos-config`, and runs `passwd` if the user has no password yet.

An existing `hosts/<hostname>/` is kept as is. `hardware-configuration.nix` is only regenerated with `--root`.

| Flag | Effect |
|---|---|
| `--host <name>` | Hostname, no prompt |
| `--user <name>` | Username, no prompt |
| `--root /mnt` | Install into a mounted system via `nixos-install` |
| `--dry-run` | Print what would be generated, write nothing |
| `--no-apply` | Write `hosts/<hostname>/` but don't build |
| `--yes` | No confirmation |

`scripts/test-install.sh` runs the installer against fake hardware.

## Layout

```text
flake.nix              inputs and host outputs
hosts/<hostname>/      default.nix, meta.nix (username), hardware-configuration.nix
system/                NixOS modules
  hardware/            GPU drivers
  boot.nix             kernel, bootloader, ly
  desktop.nix          Hyprland, Plasma, portals
  compat.nix           nix-ld, AppImage support
  network.nix          firewall, Avahi/UxPlay, Throne
  packages.nix         system packages
  ...                  audio, fonts, games, apps, locale, users, shell, nix
home/                  Home Manager
  shell/               Fish, aliases, Starship, Git
  desktop/             Hyprland (Lua), Noctalia, Nemo, GTK/Qt theme
  browsers/            LibreWolf, ungoogled-chromium
  ...                  terminals, editors, apps, media, games, cli
pkgs/                  local packages (il2cpp-inspector-redux)
assets/                wallpapers, ly animation
scripts/               update.sh, test-install.sh
private/               gitignored personal files
```
