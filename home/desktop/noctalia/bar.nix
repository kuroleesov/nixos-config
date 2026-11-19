# Верхняя панель Noctalia и её виджеты
{
  programs.noctalia.settings = {
    bar.Top = {
      font_family = "JetBrainsMono Nerd Font Mono";

      margin_edge = 0;
      margin_ends = 0;
      padding = 10;
      radius = 0;

      background_opacity = 0.6;
      scale = 1;
      thickness = 32;

      shadow = false;

      start = [
        "clock"
        "workspaces"
        "privacy"
      ];
      center = [ "active_window" ];
      end = [
        "media"
        "group:g1"
        "keyboard_layout"
        "nightlight"
        "tray"
        "notifications"
        "session"
      ];

      capsule_group = [
        {
          fill = "surface_container";
          id = "g1";
          members = [
            "network"
            "volume"
          ];
          opacity = 0.5;
          padding = 10;
          radius = 0;
        }
      ];
    };

    widget = {
      # Левая секция
      clock = {
        format = "{:%d/%m %H:%M:%S}";
        tooltip_format = "{:%H:%M:%S %A, %d %B %Y}";
        capsule = true;
        capsule_opacity = 0.5;
        capsule_padding = 10;
        capsule_radius = 0;
      };

      workspaces = {
        empty_color = "shadow";
        occupied_color = "shadow";
      };

      privacy.hide_inactive = true;

      # Центральная секция
      active_window = {
        title_scroll = "on_hover";
        max_length = 600;
      };

      # Правая секция
      media = {
        hide_when_no_media = true;
        max_length = 500;
        title_scroll = "always";
      };
    };
  };
}
