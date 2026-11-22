# Noctalia: запуск, звук, простой, геопозиция, блокировка, ночной свет, уведомления, OSD
{ config, ... }:
{
  imports = [
    ./bar.nix
    ./shell.nix
    ./theme.nix
  ];

  programs.noctalia = {
    enable = true;

    # Запуск как systemd-сервис
    systemd.enable = true;

    settings = {
      audio = {
        enable_notification_sounds = false;
        enable_power_sounds = false;
        enable_screenshot_sounds = false;
        enable_sounds = false;
        enable_volume_sounds = false;
      };

      idle = {
        pre_action_fade_seconds = 0;

        # Блокировка через 5 минут, экран гаснет через 10, сон отключён
        behavior_order = [
          "lock"
          "screen-off"
          "lock-and-suspend"
        ];
        behavior = {
          lock = {
            action = "lock";
            enabled = true;
            timeout = 300.0;
          };
          "lock-and-suspend" = {
            action = "lock_and_suspend";
            enabled = false;
            timeout = 900.0;
          };
          "screen-off" = {
            action = "screen_off";
            enabled = true;
            timeout = 600.0;
          };
        };
      };

      # Место для погоды и ночного света (address, latitude, longitude) — в private/noctalia.toml, см. ниже
      location.auto_locate = false;

      lockscreen = {
        fingerprint = false;
        transition = [ ];
      };

      nightlight = {
        enabled = true;
        temperature_night = 2200;
      };

      notification.history_retention_hours = 1;

      osd = {
        background_opacity = 0.6; # как у панели
        kinds.nightlight = false; # без OSD для ночного света
      };
    };
  };

  # Noctalia читает все *.toml в ~/.config/noctalia; личное — из private/ (папка в .gitignore), без файла ссылка просто пропускается
  xdg.configFile."noctalia/private.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-config/private/noctalia.toml";

  # Прячем .desktop Noctalia из лаунчеров
  xdg.dataFile."applications/dev.noctalia.Noctalia.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Noctalia
    Hidden=true
  '';
}
