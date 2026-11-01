{ config, pkgs, ... }:

{
  # Ссылка прямо на файл в репозитории (а не в /nix/store):
  # правишь ~/nixos-config/home/hypr/hyprland.lua и сразу `hyprctl reload`, без пересборки.
  # Папку ~/.config/hypr/dms/ DMS заполняет сам (цвета, мониторы, правила окон).
  xdg.configFile."hypr/hyprland.lua".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-config/home/hypr/hyprland.lua";

  # Для сессии «Hyprland» без UWSM: этот таргет поднимает graphical-session.target,
  # от которого стартует dms.service (его запускает hyprland.lua при старте).
  # Под «Hyprland (UWSM)» это делает сам UWSM, таргет не используется.
  systemd.user.targets.hyprland-session.Unit = {
    Description = "Hyprland session (без UWSM)";
    BindsTo = [ "graphical-session.target" ];
    Wants = [ "graphical-session-pre.target" ];
    After = [ "graphical-session-pre.target" ];
  };

  # GTK/Qt-темы, которые DMS перекрашивает под обои (matugen)
  gtk = {
    enable = true;
    # plasma-apply-colorscheme (dms-kde-colors) заменяет симлинк ~/.gtkrc-2.0 обычным файлом,
    # и второй hm-backup валит активацию — перезаписываем без бэкапа
    gtk2.force = true;
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    font = {
      name = "Google Sans Flex";
      size = 10;
    };

    # Цвета из matugen (DMS пишет dank-colors.css при смене обоев) + полупрозрачный фон,
    # который Hyprland размывает. Новые цвета подхватываются при перезапуске приложения.
    gtk3.extraCss = ''
      @import url("file://${config.xdg.configHome}/gtk-3.0/dank-colors.css");

      window.background:not(.popup):not(.tooltip) { background-color: alpha(@window_bg_color, 0.85); }
      .view, iconview, treeview.view, placessidebar, placessidebar list, .sidebar, scrolledwindow, viewport,
      headerbar, .titlebar, toolbar, paned, notebook, notebook > stack { background-color: transparent; }
      headerbar, .titlebar { background-image: none; box-shadow: none; }
      .view:selected, iconview:selected, treeview.view:selected, placessidebar row:selected {
        background-color: alpha(@accent_bg_color, 0.55);
        color: @accent_fg_color;
      }
    '';
    gtk4.extraCss = ''
      @import url("file://${config.xdg.configHome}/gtk-4.0/dank-colors.css");

      window.background:not(.popup):not(.tooltip) { background-color: alpha(@window_bg_color, 0.85); }
      .view, list:not(.boxed-list), .navigation-sidebar, toolbarview, headerbar, .top-bar, .bottom-bar,
      scrolledwindow, viewport, notebook, notebook > stack, notebook > header, stack { background-color: transparent; }
      .sidebar-pane { background-color: alpha(@sidebar_bg_color, 0.45); }
      headerbar, .top-bar, .bottom-bar { box-shadow: none; }
    '';
  };

  # Qt/KDE: DMS генерирует KDE-схему DankMatugen при смене обоев, а этот сервис
  # применяет её в kdeglobals (запускается при входе и при каждом изменении файла схемы)
  systemd.user.services.dms-kde-colors = {
    Unit.Description = "Применить matugen-схему DankMatugen к Qt/KDE";
    Service = {
      Type = "oneshot";
      ExecStart = toString (
        pkgs.writeShellScript "dms-kde-colors" ''
          kwrite=${pkgs.kdePackages.kconfig}/bin/kwriteconfig6
          # шрифт Qt/KDE-приложений (без этих ключей KDE берёт свой Noto Sans 10)
          f="Google Sans Flex,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"
          for key in font menuFont toolBarFont; do
            $kwrite --file kdeglobals --group General --key $key "$f"
          done
          $kwrite --file kdeglobals --group General --key smallestReadableFont "Google Sans Flex,8,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"
          $kwrite --file kdeglobals --group WM --key activeFont "$f"

          [ -f "$HOME/.local/share/color-schemes/DankMatugen.colors" ] || exit 0
          apply=${pkgs.kdePackages.plasma-workspace}/bin/plasma-apply-colorscheme
          $kwrite --file kdeglobals --group KDE --key widgetStyle Breeze
          $kwrite --file kdeglobals --group Icons --key Theme Papirus-Dark
          # уже активную схему plasma-apply-colorscheme пропускает — сначала переключаемся на другую
          $apply DankMatugenLight >/dev/null || true
          $apply DankMatugen
        ''
      );
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
  systemd.user.paths.dms-kde-colors = {
    Unit.Description = "Следить за схемой DankMatugen";
    Path.PathChanged = "%h/.local/share/color-schemes/DankMatugen.colors";
    Install.WantedBy = [ "graphical-session.target" ];
  };

  home.pointerCursor = {
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;
    hyprcursor.enable = true;
  };

  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
}
