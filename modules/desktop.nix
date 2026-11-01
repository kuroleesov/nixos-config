{
  inputs,
  pkgs,
  user,
  ...
}:

let
  unstableModules = "${inputs.nixpkgs-unstable}/nixos/modules";

  # Шрифт Dux Shell по умолчанию; в nixpkgs его нет, а пакет dux-shell свой экземпляр не кладёт
  google-sans-flex = pkgs.runCommand "google-sans-flex" { } ''
    install -Dm444 ${
      pkgs.fetchurl {
        name = "GoogleSansFlex.ttf";
        url = "https://raw.githubusercontent.com/google/fonts/bd8f81ddb5c74d5c8897b36ad88b440266245103/ofl/googlesansflex/GoogleSansFlex%5BROND%2Copsz%2Cslnt%2Cwdth%2Cwght%5D.ttf";
        hash = "sha256-qax3B5iFfV6KxZPO1Csi5Ap8CM7Jgxn5Kw7Mwng6d7o=";
      }
    } $out/share/fonts/truetype/GoogleSansFlex.ttf
  '';
in
{
  # Модули Dux Shell из unstable (в 26.05 ещё старые dms-shell/dms-greeter, они конфликтуют с новыми)
  disabledModules = [
    "programs/wayland/dms-shell.nix"
    "services/display-managers/dms-greeter.nix"
  ];
  imports = [
    "${unstableModules}/programs/wayland/dux-shell.nix"
    "${unstableModules}/services/display-managers/dux-greeter.nix"
  ];

  # Hyprland через UWSM: правильно поднимает graphical-session.target,
  # от которого стартует systemd-сервис Dux Shell (dms.service).
  programs.hyprland = {
    enable = true;
    # 0.55.4 из stable падает в layoutMinSize; берём свежий из unstable
    package = pkgs.unstable.hyprland;
    portalPackage = pkgs.unstable.xdg-desktop-portal-hyprland;
    withUWSM = true;
    xwayland.enable = true;
  };

  # Dux Shell (бывший DankMaterialShell)
  programs.dux-shell = {
    enable = true;
    systemd = {
      enable = true;
      restartIfChanged = true;
    };
  };

  # Экран входа Dux Greeter (greetd) вместо SDDM; подтягивает обои и тему из Dux Shell
  services.displayManager.dux-greeter = {
    enable = true;
    compositor.name = "hyprland";
    configHome = "/home/${user}";
  };
  services.displayManager.defaultSession = "hyprland-uwsm";

  # KDE Plasma оставлен запасной сессией (выбирается на экране входа).
  # Когда освоишься в Hyprland — можно удалить эту строку.
  services.desktopManager.plasma6.enable = true;

  services.xserver.xkb = {
    layout = "us,ru";
    options = "grp:alt_shift_toggle";
  };

  # Всё, что ждёт DMS и Hyprland
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.dms-greeter.enableGnomeKeyring = true;
  security.polkit.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      inter
      google-sans-flex
      material-symbols
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
    ];
    fontconfig.defaultFonts = {
      sansSerif = [ "Google Sans Flex" "Inter" "Noto Sans" ];
      monospace = [ "JetBrainsMono Nerd Font" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  environment.systemPackages = with pkgs; [
    kitty
    wl-clipboard
    cliphist
    playerctl
    brightnessctl
    pavucontrol
    networkmanagerapplet
    adw-gtk3
    papirus-icon-theme
    kdePackages.qt6ct
    hyprpicker
    grim
    slurp
  ];
}
