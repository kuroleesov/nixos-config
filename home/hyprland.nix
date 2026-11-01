{ config, pkgs, ... }:

{
  # Ссылки прямо на файлы в репозитории (а не в /nix/store):
  # правишь ~/nixos-config/home/hypr/ и сразу `hyprctl reload`, без пересборки.
  # ~/.config/hypr/noctalia.lua генерирует сам Noctalia.
  xdg.configFile."hypr/hyprland.lua".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-config/home/hypr/hyprland.lua";
  xdg.configFile."hypr/config".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-config/home/hypr/config";

  # Для сессии «Hyprland» без UWSM: этот таргет поднимает graphical-session.target,
  # от которого стартует Noctalia (hyprland.lua запускает таргет при старте).
  # Под «Hyprland (UWSM)» это делает сам UWSM, таргет не используется.
  systemd.user.targets.hyprland-session.Unit = {
    Description = "Hyprland session (без UWSM)";
    BindsTo = [ "graphical-session.target" ];
    Wants = [ "graphical-session-pre.target" ];
    After = [ "graphical-session-pre.target" ];
  };

  gtk = {
    enable = true;
    # Noctalia применяет KDE-схему через plasma-apply-colorscheme, он заменяет симлинк ~/.gtkrc-2.0 обычным файлом,
    # и второй hm-backup валит активацию
    gtk2.force = true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    font = {
      name = "Google Sans Flex";
      size = 10;
    };
  };

  # Остальное по курсору (имя, размер, gtk) и color-scheme задаёт repinek/modules/desktop/theme/user.nix
  home.pointerCursor.hyprcursor.enable = true;

  services.hyprpolkitagent.enable = true;

  home.packages = with pkgs; [
    hyprshot
    satty
  ];
}
