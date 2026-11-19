# Noctalia: запуск, звук, простой, геопозиция, блокировка, ночной свет, уведомления, OSD
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

      location = {
        auto_locate = false; # с VPN автоопределение места ненадёжно

        # Для погоды и ночного света
        address = "Moscow, Russia";
        latitude = 55.7558;
        longitude = 37.6173;
      };

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

  # Прячем .desktop Noctalia из лаунчеров
  xdg.dataFile."applications/dev.noctalia.Noctalia.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Noctalia
    Hidden=true
  '';
}
