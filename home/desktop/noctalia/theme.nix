# Тема Noctalia, обои и пользовательские шаблоны (fastfetch, kitty, vysh, обои)
{ config, lib, pkgs, ... }:
let
  cfgDir = "${config.xdg.configHome}/noctalia/wallpaper";

  # true — генерируемые обои assets/wallpapers/nix-wallpaper.svg в цветах темы (перебивают выбор при каждой смене темы);
  # false — свои обои через Super + W (по умолчанию из ~/Pictures), выбор хранится в ~/.local/state/noctalia/settings.toml
  nixWallpaper = false;

  # Шаблон ~/.config/vysh/colors.json (формат docs/THEMES.md в vysh): .default — роли текущего режима Noctalia,
  # поэтому одинаковые для dark и light; недостающие роли M3 vysh достраивает из seed
  color = name: "{{colors.${name}.default.hex}}";
  roles = lib.genAttrs [
    "primary" "on_primary" "primary_container" "on_primary_container"
    "secondary" "on_secondary" "secondary_container" "on_secondary_container"
    "tertiary" "on_tertiary" "tertiary_container" "on_tertiary_container"
    "error" "on_error" "error_container" "on_error_container"
    "surface" "on_surface" "on_surface_variant" "inverse_surface"
    "surface_container_lowest" "surface_container_low" "surface_container"
    "surface_container_high" "surface_container_highest"
    "outline" "outline_variant"
  ] color;
  ansi = [ "black" "red" "green" "yellow" "blue" "magenta" "cyan" "white" ];
  vyshColors = builtins.toJSON {
    seed = color "primary";
    dark = roles;
    light = roles;
    terminal = {
      background = color "terminal_background";
      foreground = color "terminal_foreground";
      colors = map (c: color "terminal_normal_${c}") ansi ++ map (c: color "terminal_bright_${c}") ansi;
    };
  };
in
{
  home.packages = lib.optional nixWallpaper pkgs.librsvg;

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

          # vysh в режиме «Из дотов» сам читает этот путь и обновляет цвета при каждой записи файла
          vysh = {
            input_path = "templates/vysh.json";
            output_path = "~/.config/vysh/colors.json";
          };

          wallpaper = lib.mkIf nixWallpaper {
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

    # С nixWallpaper картинка генерируется из шаблона wallpaper
    wallpaper = {
      fill_mode = "crop";
      default = lib.mkIf nixWallpaper { path = "${cfgDir}/latest.png"; };

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
    "noctalia/templates/vysh.json".text = vyshColors;
    "noctalia/templates/nix-wallpaper.svg" = lib.mkIf nixWallpaper {
      source = ../../../assets/wallpapers/nix-wallpaper.svg;
    };
  };
}
