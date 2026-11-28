# Файловый менеджер Nemo: пакеты и настройки dconf
{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    # стандартные расширения Mint (nemo-python, nemo-fileroller, эмблемы, цвет папок)
    # + предпросмотр по пробелу и пункты меню для AppImage
    (nemo-with-extensions.override {
      extensions = [
        nemo-preview
        (import ./nemo-appimage.nix { inherit pkgs; })
      ];
    })
    file-roller # архиватор
    ffmpegthumbnailer # миниатюры видео
  ];

  dconf.settings = {
    "org/cinnamon/desktop/applications/terminal" = {
      exec = "kitty";
      exec-arg = "-e";
    };

    "org/nemo/list-view".default-zoom-level = "standard";

    "org/nemo/plugins" = {
      # Прячем ненужные действия контекстного меню
      disabled-actions = [
        "set-as-background.nemo_action"
        "mount-archive.nemo_action"
        "change-background.nemo_action"
        "add-desklets.nemo_action"
        "90_new-launcher.nemo_action"
        "set-resolution.nemo_action"
      ];
    };

    "org/nemo/preferences" = {
      # Вид
      default-folder-viewer = "list-view";

      # Поведение: один и тот же вид в каждой папке
      ignore-view-metadata = true;
      inherit-folder-viewer = true;

      # Отображение
      date-format = "iso"; # дата в формате ISO 8601

      # Панель инструментов
      show-compact-view-icon-toolbar = false;
      show-computer-icon-toolbar = true;
      show-edit-icon-toolbar = false;
      show-hidden-files = false;
      show-home-icon-toolbar = true;
      show-new-folder-icon-toolbar = true;
      show-open-in-terminal-toolbar = true;
      show-search-icon-toolbar = false;

      # Предпросмотр
      thumbnail-limit = lib.hm.gvariant.mkUint64 1073741824; # 1 GiB
    };

    "org/nemo/preferences/menu-config".selection-menu-favorite = false;

    "org/nemo/search".search-sort-column = "name"; # сортировка результатов поиска по имени

    "org/nemo/window-state" = {
      network-expanded = false; # сетевой раздел свёрнут
      sidebar-bookmark-breakpoint = 0; # закладки отдельно от «Мой компьютер» в боковой панели
    };
  };
}
