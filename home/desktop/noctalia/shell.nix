# Оболочка Noctalia: общие настройки, лаунчер, меню сессии и центр управления
{
  programs.noctalia.settings = {
    shell = {
      # Нужен systemd-сервис, чтобы приложения, запущенные из Noctalia,
      # не убивались при его перезапуске
      launch_apps_as_systemd_services = true;

      screen_time_enabled = true;
      settings_show_advanced = true;
      app_icon_colorize = true;
      external_ip_enabled = true; # внешний IP во вкладке сети центра управления
      time_format = "{:%H:%M:%S}";

      shadow.direction = "center";

      corner_radius_scale = 0;

      panel = {
        open_near_click_control_center = true;
        open_near_click_session = true;
      };

      launcher = {
        layout = "simple";
        categories = false;
        pinned = [ "org.telegram.desktop" ];
      };

      # L - блокировка; R - перезагрузка; S - выключение
      session.actions = [
        {
          action = "lock";
          enabled = true;
          shortcut = "L";
        }
        {
          action = "logout";
          enabled = false;
          shortcut = "2";
        }
        {
          action = "lock_and_suspend";
          enabled = false;
          shortcut = "3";
        }
        {
          action = "reboot";
          enabled = true;
          shortcut = "R";
        }
        {
          action = "shutdown";
          enabled = true;
          shortcut = "S";
          variant = "destructive";
        }
      ];
    };

    control_center = {
      sidebar = "full";
      width = 800;

      # Noctalia поддерживает не больше шести ярлыков
      shortcuts = [
        { type = "caffeine"; }
        { type = "nightlight"; }
        { type = "notification"; }
        { type = "dark_mode"; }
        { type = "clipboard"; }
        { type = "screen_time"; }
      ];
    };
  };
}
