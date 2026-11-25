# Hyprland: симлинки на конфиги, сессия без UWSM, polkit и скриншоты
{ config, pkgs, ... }:

{
  # Ссылки прямо на файлы в репозитории (а не в /nix/store):
  # правишь ~/nixos-config/home/desktop/hypr/ и сразу `hyprctl reload`, без пересборки.
  # ~/.config/hypr/noctalia.lua генерирует сам Noctalia.
  xdg.configFile."hypr/hyprland.lua".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-config/home/desktop/hypr/hyprland.lua";
  xdg.configFile."hypr/config".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-config/home/desktop/hypr/config";

  # Галка «Разрешить токен восстановления» в выборе экрана включена по умолчанию:
  # OBS, Discord и т.п. не спрашивают экран заново при каждом подключении
  xdg.configFile."hypr/xdph.conf".text = ''
    screencopy {
        allow_token_by_default = true
    }
  '';

  # Для сессии «Hyprland» без UWSM: этот таргет поднимает graphical-session.target,
  # от которого стартует Noctalia (hyprland.lua запускает таргет при старте).
  # Под «Hyprland (UWSM)» это делает сам UWSM, таргет не используется.
  systemd.user.targets.hyprland-session.Unit = {
    Description = "Hyprland session (без UWSM)";
    BindsTo = [ "graphical-session.target" ];
    Wants = [ "graphical-session-pre.target" ];
    After = [ "graphical-session-pre.target" ];
  };

  services.hyprpolkitagent.enable = true;

  home.packages = with pkgs; [
    hyprshot
    satty
  ];
}
