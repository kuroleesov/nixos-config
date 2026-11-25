# Рабочий стол: Hyprland (UWSM), Plasma, раскладка, портали, Thunar, печать
{ pkgs, user, ... }:

{
  # Hyprland через UWSM: правильно поднимает graphical-session.target,
  # от которого стартует systemd-сервис Noctalia.
  programs.hyprland = {
    enable = true;
    # 0.55.4 из stable падает в layoutMinSize; берём свежий из unstable
    package = pkgs.unstable.hyprland;
    portalPackage = pkgs.unstable.xdg-desktop-portal-hyprland;
    withUWSM = true;
    xwayland.enable = true;
  };

  services.displayManager.defaultSession = "hyprland-uwsm";

  # KDE Plasma оставлен запасной сессией (выбирается на экране входа).
  # Когда освоишься в Hyprland — можно удалить эту строку.
  services.desktopManager.plasma6.enable = true;

  services.xserver.xkb = {
    layout = "us,ru";
    options = "grp:alt_shift_toggle";
  };

  # Всё, что ждут Noctalia и Hyprland
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;
  services.gnome.gnome-keyring.enable = true;
  security.polkit.enable = true;
  # rebuild с новыми пакетами перезапускает polkit, а запущенный при входе hyprpolkitagent у нового polkitd
  # не зарегистрирован → pkexec «no polkit agent». Перезапускаем агент следом; «+» — от root, «-» — при загрузке сессии ещё нет
  systemd.services.polkit.serviceConfig.ExecStartPost =
    "+-${pkgs.systemd}/bin/systemctl --user -M ${user}@ --no-block try-restart hyprpolkitagent.service";

  # Единый диалог выбора файлов: всё, что идёт через портал (Flatpak, AppImage, GTK4, Chromium/Electron),
  # получает GTK-диалог хоста. Маршруты в секции hyprland: hyprland-portals.conf из xdph
  # перебивает common, а файл из /etc/xdg побеждает файл из пакета.
  # Plasma читает свой kde-portals.conf и этим не затрагивается
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config = {
      hyprland = {
        default = [
          "hyprland"
          "gtk"
        ];
        "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "hyprland" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "hyprland" ];
      };
      common = {
        default = [ "gtk" ];
        "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
      };
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

  # Thunar: файловый менеджер
  programs.thunar.enable = true;
  programs.thunar.plugins = with pkgs; [
    thunar-archive-plugin
    thunar-volman
  ];
  programs.xfconf.enable = true; # Thunar сохраняет настройки
  services.gvfs.enable = true; # корзина, флешки, сеть в Thunar
  services.tumbler.enable = true; # превью картинок в Thunar

  services.printing.enable = true;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1"; # Electron/Chromium (VSCode и т.п.) нативно на Wayland
    # кодеки GStreamer для Showtime, Loupe и превью в Nemo
    GST_PLUGIN_SYSTEM_PATH_1_0 = "/run/current-system/sw/lib/gstreamer-1.0";
  };
}
