# Тема: GTK, Qt и курсор (цвета задаёт Noctalia)
{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    adw-gtk3
  ];

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
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };

  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
    gtk-theme = "adw-gtk3";
  };

  qt = {
    enable = true;
    platformTheme.name = "qtct";
  };

  # Прячем из меню приложений настройки qt5ct/qt6ct: темой управляет Noctalia
  xdg.dataFile = {
    "applications/qt5ct.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Qt5 Settings
      Hidden=true
    '';
    "applications/qt6ct.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Qt6 Settings
      Hidden=true
    '';
  };

  # Цветовая схема Qt берётся из файлов Noctalia
  xdg.configFile = {
    "qt5ct/qt5ct.conf".text = ''
      [Appearance]
      custom_palette=true
      color_scheme_path=${config.home.homeDirectory}/.config/qt5ct/colors/noctalia.conf
    '';

    "qt6ct/qt6ct.conf".text = ''
      [Appearance]
      custom_palette=true
      color_scheme_path=${config.home.homeDirectory}/.config/qt6ct/colors/noctalia.conf
    '';
  };

  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    x11.enable = true;
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 20;
    hyprcursor.enable = true;
  };
}
