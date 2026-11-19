# Терминалы: kitty и alacritty
{ ... }:

{
  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 12;
    };

    settings = {
      # --- окно ---
      confirm_os_window_close = 0;
      hide_window_decorations = "yes"; # рамки рисует Hyprland
      window_padding_width = 10;
      background_opacity = "0.92"; # + blur из Hyprland
      dynamic_background_opacity = "yes"; # Ctrl+Shift+A, затем M/L — прозрачность на лету
      remember_window_size = "no";
      initial_window_width = "120c";
      initial_window_height = "34c";

      # --- курсор ---
      cursor_shape = "beam";
      cursor_trail = 3; # «хвост» за курсором при прыжках
      cursor_trail_decay = "0.1 0.4";

      # --- прокрутка ---
      scrollback_lines = 20000;
      scrollback_pager_history_size = 64; # МБ истории для Ctrl+Shift+H
      wheel_scroll_multiplier = "3.0";

      # --- мышь, ссылки, вставка ---
      mouse_hide_wait = "2.0";
      url_style = "curly";
      show_hyperlink_targets = "yes";
      strip_trailing_spaces = "smart";
      paste_actions = "quote-urls-at-prompt,confirm-if-large";

      # --- звук и уведомления ---
      enable_audio_bell = "no";
      window_alert_on_bell = "yes";
      # Уведомление (в Noctalia), если команда шла дольше 15 с, а окно kitty было скрыто
      notify_on_cmd_finish = "invisible 15.0";

      # --- отзывчивость ---
      repaint_delay = 8;
      input_delay = 2;
      sync_to_monitor = "yes";

      # --- вкладки ---
      tab_bar_edge = "top";
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";
      tab_bar_min_tabs = 2;
      tab_title_template = "{index}: {title}";
      tab_title_max_length = 30;

      # --- сплиты ---
      enabled_layouts = "splits,stack";

      # Удалённое управление (kitten'ы, скрипты) — только через сокет
      allow_remote_control = "socket-only";
      listen_on = "unix:@kitty-{kitty_pid}";
    };

    keybindings = {
      # Ctrl+C копирует, если что-то выделено, иначе прерывает команду как обычно
      "ctrl+c" = "copy_or_interrupt";
      "ctrl+v" = "paste_from_clipboard";

      # Новая вкладка / сплит — в текущей папке
      "ctrl+shift+t" = "new_tab_with_cwd";
      "ctrl+shift+enter" = "launch --cwd=current --location=vsplit"; # сплит справа
      "ctrl+shift+backslash" = "launch --cwd=current --location=hsplit"; # сплит снизу
      "ctrl+shift+z" = "toggle_layout stack"; # развернуть текущий сплит на всё окно

      # Перемещение между сплитами
      "alt+left" = "neighboring_window left";
      "alt+right" = "neighboring_window right";
      "alt+up" = "neighboring_window up";
      "alt+down" = "neighboring_window down";

      # Alt+1..9 — перейти на вкладку
      "alt+1" = "goto_tab 1";
      "alt+2" = "goto_tab 2";
      "alt+3" = "goto_tab 3";
      "alt+4" = "goto_tab 4";
      "alt+5" = "goto_tab 5";
      "alt+6" = "goto_tab 6";
      "alt+7" = "goto_tab 7";
      "alt+8" = "goto_tab 8";
      "alt+9" = "goto_tab 9";

      # Размер шрифта как в браузере
      "ctrl+equal" = "change_font_size all +1.0";
      "ctrl+minus" = "change_font_size all -1.0";
      "ctrl+0" = "change_font_size all 0";

      # Поиск по выводу терминала через fzf
      "ctrl+shift+f" =
        "launch --type=overlay --stdin-source=@screen_scrollback --stdin-add-formatting=no fzf --no-sort --no-mouse --exact -i --tac";
    };

    # Цвета генерирует Noctalia (шаблон в home/desktop/noctalia/theme.nix); пока файла нет, kitty его пропускает.
    extraConfig = ''
      include themes/noctalia.conf
    '';
  };

  # перезаписывать файл, даже если его заменили не через Home Manager
  xdg.configFile."alacritty/alacritty.toml".force = true;

  programs.alacritty = {
    enable = true;

    settings = {
      general.import = [
        "~/.config/alacritty/themes/noctalia.toml"
      ];

      window = {
        padding = {
          x = 12;
          y = 12;
        };
        dynamic_padding = true;
        opacity = 0.8;
        blur = true;
      };

      scrolling = {
        history = 10000;
        multiplier = 3;
      };

      font = {
        normal = {
          family = "JetBrainsMono Nerd Font Mono";
          style = "Regular";
        };
        bold = {
          family = "JetBrainsMono Nerd Font Mono";
          style = "Bold";
        };
        italic = {
          family = "JetBrainsMono Nerd Font Mono";
          style = "Italic";
        };
        bold_italic = {
          family = "JetBrainsMono Nerd Font Mono";
          style = "Bold Italic";
        };
        size = 11;
      };

      selection = {
        save_to_clipboard = true;
      };

      cursor = {
        style = {
          shape = "Beam";
          blinking = "On";
        };
      };
    };
  };
}
