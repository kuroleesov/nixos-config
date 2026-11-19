# Тема Noctalia, обои и пользовательские шаблоны (fastfetch, kitty, обои)
{ config, pkgs, ... }:
let
  cfgDir = "${config.xdg.configHome}/noctalia/wallpaper";
in
{
  home.packages = [ pkgs.librsvg ];

  programs.noctalia.settings = {
    theme = {
      # Палитра не берётся из обоев
      builtin = "Catppuccin";

      community_palette = "Lilac AMOLED";
      mode = "dark";

      templates = {
        builtin_ids = [
          "alacritty"
          "btop"
          "hyprland"
          "gtk3"
          "gtk4"
          "kcolorscheme"
          "qt"
        ];
        # Без obsidian и ungoogled-chromium: их шаблоны запускают незакреплённые shell-хуки при каждой смене темы
        community_ids = [
          "pywalfox"
          "discord"
          "vscode"
          "obs"
          "zed"
          "codex"
        ];

        user = {
          fastfetch = {
            input_path = "templates/fastfetch.jsonc";
            output_path = "~/.config/fastfetch/config.jsonc";
          };

          # Встроенный шаблон kitty правит kitty.conf, а это симлинк Home Manager, поэтому свой шаблон без apply.sh; подключение темы в home/terminals.nix
          kitty = {
            input_path = "templates/kitty.conf";
            output_path = "~/.config/kitty/themes/noctalia.conf";
          };

          wallpaper = {
            input_path = "templates/nix-wallpaper.svg";
            output_path = "wallpaper/noctalia-wallpaper.svg";

            # Уникальный PNG из SVG-шаблона при каждом templates-apply:
            # wallpaper-set пропускает перезагрузку при том же пути, поэтому добавляем метку времени.
            # Хранятся два последних файла, чтобы у latest.png всегда была рабочая цель при старте
            post_hook = ''
              stamp=$(date +%s%N) && \
              rsvg-convert "${cfgDir}/noctalia-wallpaper.svg" -o "${cfgDir}/generated-wallpaper-$stamp.png" && \
              ln -sf "generated-wallpaper-$stamp.png" "${cfgDir}/latest.png" && \
              ls -t "${cfgDir}"/generated-wallpaper-*.png 2>/dev/null | tail -n +3 | xargs rm -f -- && \
              noctalia msg wallpaper-set "${cfgDir}/generated-wallpaper-$stamp.png"
            '';
          };
        };
      };
    };

    # Картинка генерируется из шаблона wallpaper
    wallpaper = {
      fill_mode = "crop";
      default.path = "${cfgDir}/latest.png";

      transition = [
        "disc"
        "fade"
        "wipe"
      ];
    };
  };

  xdg.configFile = {
    "noctalia/templates/fastfetch.jsonc".source = ./templates/fastfetch.jsonc;
    "noctalia/templates/kitty.conf".source =
      "${pkgs.noctalia}/share/noctalia/assets/templates/kitty/kitty.conf";
    "noctalia/templates/nix-wallpaper.svg".source = ../../../assets/wallpapers/nix-wallpaper.svg;
  };
}
