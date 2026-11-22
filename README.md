# NixOS Configuration
>**Warning** These dotfiles were mostly vibecoded, so be careful.  
A personal NixOS setup built around **Hyprland**, **Noctalia**, and **Fish**.

> This configuration is provided as-is. It was built primarily for personal use, so review the scripts and configuration before applying them to your system.

This guide explains how to deploy the configuration on an **existing NixOS installation**. It does not cover installing NixOS itself.

## Requirements

- An existing, working NixOS installation.
- An Intel or AMD 64-bit system. ARM and Apple Silicon are not supported by this configuration.
- At least 8 GB of RAM.
- At least 100 GB of available disk space is recommended. The full software set is fairly large and includes applications such as Steam and DaVinci Resolve.
- A reliable internet connection. The initial build may download more than 10 GB of data.
- Approximately one to two hours for the initial setup. Some packages may need to be built locally.

> **Important:** Applying this configuration changes system-level settings and installs or replaces packages. Back up important data and review the configuration before proceeding.

## Installation

### 1. Open a terminal

Log in to your existing NixOS installation and open a terminal.

### 2. Make Git available

Run:

```bash
nix-shell -p git
```

Wait until the shell prompt changes to indicate that the temporary environment is active.

### 3. Clone the repository

```bash
git clone https://github.com/kuroleesov/nixos-config.git ~/nixos-config
```

If the directory already exists, the repository has likely been cloned before. You can continue to the next step.

### 4. Enter the repository directory

```bash
cd ~/nixos-config
```

### 5. Run the installer

```bash
./install.sh
```

The installer will ask for a few details:

| Prompt | What to enter |
|---|---|
| `Hostname [...]:` | Choose a hostname, for example `workstation`. Use lowercase Latin letters, numbers, and hyphens only. |
| `Username [your-user]:` | Press `Enter` to use the current default, provided it matches your existing NixOS username. |
| `Create hosts/... for user ...? [y/N]` | Enter `y` and press `Enter`. |
| `[sudo] password for ...:` | Enter your user password. The terminal will not display characters while you type; this is expected. |

The initial build can take a while because packages may need to be downloaded and compiled. Keep the terminal open and do not shut down the computer while the process is running.

The installer may request your password again during the process. Enter the same password when prompted.

When the installer reports that the system configuration has been applied successfully, reboot:

```bash
reboot
```

## First login

- At the login screen, enter your password.
- The default session is **Hyprland (UWSM)**.
- If Hyprland does not start correctly, use the session selector to choose **Plasma** as a fallback desktop environment.
- **Super** refers to the Windows key on most keyboards.

### Keyboard shortcuts

| Shortcut | Action |
|---|---|
| `Super + Enter` or `Super + Q` | Open the terminal |
| `Super + Space` (or `R`, `D`) | Search for and launch applications |
| `Super + B` | Open the browser |
| `Super + E` | Open the file manager |
| `Super + C` | Close the active window |
| `Super + F` | Toggle fullscreen |
| `Super + V` | Toggle floating mode for the active window |
| `Super + 1` … `Super + 0` | Switch to workspaces 1–10 |
| `Super + Shift + number` | Move the active window to another workspace |
| `Super + arrow keys` | Focus an adjacent window |
| `Super + Shift + arrow keys` | Move the active window |
| `Super + Ctrl + arrow keys` | Resize the active window |
| `Super + A` | Open the control center (audio, network, Bluetooth) |
| `Super + N` | Open notifications |
| `Super + W` | Open wallpaper controls |
| `Super + ,` | Open panel settings |
| `Super + L` | Lock the screen |
| `Super + X` | Open power options |
| `Super + Shift + E` | Exit the current session immediately |
| `Print` | Capture a selected screen area; `Ctrl + Print` captures the full screen |
| `Alt + Shift` | Switch keyboard layout (English / Russian) |

## Personalizing the configuration

The configuration contains some personal defaults. You may want to adjust them after installation.

Open the repository in VS Code with:

```bash
ncode
```

Common settings:

- **Timezone and locale:** `system/locale.nix`. The current defaults use Moscow time, an English interface, and Russian date and number formats.
- **Location for weather and night-light features:** `home/desktop/noctalia/default.nix`, in the `location` section.
- **System packages:** `system/packages.nix`. Remove entries for applications you do not need, such as Discord, Spotify, or DaVinci Resolve.
- **Application-specific configuration:** `home/apps.nix`, `home/media.nix`, `home/games.nix` (including osu! and Steam Guard), and `home/editors.nix` (Zed).
- **Hyprland keybindings:** `home/desktop/hypr/config/keybinds.lua`. Changes can be applied immediately with `hr`; a full system rebuild is not required.

After editing Nix configuration files, apply the changes with:

```bash
rebuild
```

## Useful commands

| Command | Description |
|---|---|
| `rebuild` | Apply the current configuration |
| `upd` | Update all inputs and apply the updated configuration |
| `rbt` | Test configuration changes before rebooting, without modifying the boot menu |
| `ndiff` | Show changes since the previous `rebuild` |
| `nclean` | Remove old system generations and free disk space |
| `ncode` | Open the configuration in VS Code |

### Rolling back a change

If the system stops working after running `rebuild` or `upd`, reboot the computer.

When the boot menu appears, press an arrow key to stop the countdown. Select the previous NixOS generation using the arrow keys and press `Enter`. This starts the previously working system generation.

## Troubleshooting

- **`Error: this script only works on NixOS`** — Run the installer from an existing NixOS installation.
- **`Error: run without sudo`** — Start the script as your regular user with `./install.sh`. Do not prefix the command with `sudo`; the script will request elevated permissions when needed.
- **`nix-shell: command not found` or `git: command not found`** — Make sure you are running NixOS and have started the temporary Git environment with `nix-shell -p git`.
- **The installation was interrupted** (for example, because of a build error or lost internet connection) — Open a terminal and run the installer again. It is designed to resume the setup:
  ```bash
  cd ~/nixos-config
  ./install.sh
  ```
- **`Error: invalid hostname`** — Hostnames must not contain uppercase letters, spaces, or underscores. Use a name such as `workstation` or `my-pc`.
- **A black screen appears after reboot** — This can happen with some NVIDIA configurations. Reboot and select the previous NixOS generation from the boot menu, or choose **Plasma** at the login screen.
- **An older NVIDIA GPU is not working** (GTX 600/700 series and older) — These GPUs require the `legacy_470` driver. The installer does not select it automatically. In `hosts/<hostname>/default.nix`, replace `legacy_580` with `legacy_470`, then run `rebuild`.
- **Running inside a virtual machine** — Hyprland requires 3D acceleration. Enable it in your VM settings. If it still does not work, use **Plasma**.

## For advanced users

### What `install.sh` does

The installer detects the system hardware and creates a host configuration under `hosts/<hostname>/`.

- **GPU detection:** Selects the NVIDIA, AMD, or Intel configuration from `system/hardware/<nvidia|amd|intel>.nix`. For NVIDIA GPUs older than Turing (before RTX 20xx / GTX 16xx), it disables open kernel modules and selects the `legacy_580` driver. Kepler-generation GPUs and older require `legacy_470`, which must be configured manually. On laptops with both NVIDIA and integrated graphics, it configures PRIME offload (`nvidia-offload <program>`). On desktops, it configures the discrete GPU.
- **Bootloader detection:** Uses systemd-boot on UEFI systems and GRUB on legacy BIOS systems, targeting the physical disk containing the root filesystem (including LUKS/LVM/btrfs setups).
- **Bluetooth:** Enables Bluetooth support when compatible hardware is detected.
- **Virtualization:** Detects QEMU/KVM, VirtualBox, and VMware, then enables the corresponding guest drivers.
- **Hardware configuration:** Generates `hardware-configuration.nix` using `nixos-generate-config`. It determines `system.stateVersion` from the existing `/etc/nixos/configuration.nix` when possible, otherwise using the current version.

After generating the host configuration, the installer applies the configuration, copies the repository to `/home/<user>/nixos-config`, and sets the user's password if one is not already configured.

If `hosts/<hostname>/` already exists, the installer preserves its `default.nix` and `meta.nix` files and applies the existing host configuration. It regenerates `hardware-configuration.nix` only when using `--root`.

### Installer options

| Option | Description |
|---|---|
| `--host <name>` | Set the hostname without an interactive prompt |
| `--user <name>` | Set the username without an interactive prompt |
| `--root /mnt` | Target an already-mounted system root |
| `--dry-run` | Show the files and changes that would be generated without applying them |
| `--no-apply` | Generate configuration files without applying the configuration |
| `--yes` | Skip interactive confirmation prompts |

The installer can be tested against simulated hardware with:

```bash
scripts/test-install.sh
```

### Repository structure

```text
nixos-config/
├── flake.nix                     # Flake inputs and host builds
├── hosts/                        # Per-machine configuration
│   └── <hostname>/
│       ├── default.nix           # Host-specific system configuration
│       ├── meta.nix              # Host metadata, including username
│       └── hardware-configuration.nix
├── system/                       # System-wide NixOS configuration
│   ├── hardware/                 # GPU drivers and hardware modules
│   ├── nix.nix                   # Nix settings, overlays, nh, nix-ld
│   ├── boot.nix                  # Kernel, bootloader settings, ly
│   ├── desktop.nix               # Hyprland, Plasma fallback, portals, etc.
│   ├── fonts.nix                 # System fonts
│   ├── audio.nix                 # PipeWire
│   ├── network.nix               # Networking, firewall, Avahi/UxPlay, Throne
│   ├── games.nix                 # Steam and GameMode
│   ├── apps.nix                  # Firefox, Claude Desktop, Flatpak, etc.
│   ├── packages.nix              # System package list
│   ├── locale.nix                # Locale and timezone
│   ├── users.nix                 # User accounts
│   └── shell.nix                 # System-level Fish configuration
├── home/                         # Home Manager configuration
│   ├── shell/                    # Fish, aliases, Starship, Git, CLI tools
│   ├── desktop/
│   │   ├── hypr/                 # Hyprland configuration (Lua)
│   │   └── noctalia/             # Noctalia configuration
│   ├── browsers/                 # LibreWolf and Chromium
│   ├── terminals.nix             # Kitty and Alacritty
│   ├── editors.nix               # Zed
│   ├── apps.nix                  # Desktop applications
│   ├── media.nix                 # Media applications
│   ├── games.nix                 # Games and related configuration
│   └── cli.nix                   # Command-line applications
├── pkgs/                         # Custom packages
│   └── il2cpp-inspector-redux/
├── assets/                       # Wallpapers and ly animations
├── scripts/
│   ├── update.sh                 # Update inputs, check, and rebuild
│   └── test-install.sh           # Test installer against simulated hardware
└── private/                      # Local, untracked personal settings
```

### Configuration notes

- **Adding an application:** Add a package to `system/packages.nix` for a system-wide installation, or to the appropriate `home.packages` list in `home/` for a user-level installation. For applications with NixOS or Home Manager options, configure the relevant `programs.<name>` block in the appropriate module.
- **Hyprland:** Files in `home/desktop/hypr/` are linked into the active configuration. Most changes can be applied immediately with `hr` (`hyprctl reload`) without rebuilding the system.
- **Personal settings:** Machine-specific details such as server addresses, personal functions, Git identity, and location belong in `private/`. Fish loads `*.fish` files at startup, Git uses `gitconfig`, and Noctalia reads `noctalia.toml` for location-related settings such as weather and night light. This directory is listed in `.gitignore` and is not committed to the repository. Copy it manually when setting up another machine.
- **Opening configuration files:** Use `nconf` for Neovim, `ncode` for VS Code, `hconf` for the Hyprland Lua configuration, or `dt` to change to the repository directory.
