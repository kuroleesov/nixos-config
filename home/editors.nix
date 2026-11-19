# Редактор Zed: расширения, темы, LSP и настройки интерфейса
{ pkgs, ... }:
{
  programs.zed-editor = {
    enable = true;

    mutableUserSettings = true; # чтобы тему можно было менять из самого Zed

    extensions = [
      # Языки
      "nix"
      "lua"

      # Темы
      "catppuccin"
      "catppuccin-black-theme"
      "everforest"
      "rose-pine-theme"
    ];

    userSettings = {
      # Общее
      telemetry = {
        diagnostics = false;
        metrics = false;
        anthropic_retention = false;
      };

      # Оформление
      theme = "Catppuccin Mocha";
      icon_theme = "Zed (Default)";

      buffer_font_family = "JetBrainsMono Nerd Font Mono";
      buffer_font_size = 16;
      buffer_font_features = {
        calt = true;
        liga = true;
      };

      ui_font_family = "JetBrainsMono Nerd Font Mono";
      ui_font_size = 16;
      ui_font_features = {
        calt = true;
        liga = true;
      };

      cursor_animation.enabled = true;

      # Управление
      vim_mode = true;
      vim.toggle_relative_line_numbers = true;
      soft_wrap = "editor_width";

      # Редактор
      autosave.after_delay.milliseconds = 3000;

      which_key = {
        enabled = true;
        delay_ms = 100;
      };

      # Языки и инструменты
      languages = {
        Nix = {
          language_servers = [
            "nixd"
            "!nil"
          ]; # nixd вместо nil
          formatter.external = {
            command = "alejandra";
            arguments = [
              "--quiet"
              "--"
            ];
          };
        };
        Python = {
          language_servers = [
            "ty"
            "!basedpyright"
          ]; # ty вместо basedpyright
          # Ruff сортирует импорты и форматирует
          code_actions_on_format."source.organizeImports.ruff" = true;
          formatter.language_server.name = "ruff";
        };
        TypeScript.tab_size = 4;
        JavaScript.tab_size = 4;
      };

      lsp = {
        vtsls.settings = {
          typescript.updateImportsOnFileMove.enabled = "always";
          javascript.updateImportsOnFileMove.enabled = "always";
        };
        # Заглушки Hyprland API для lua-language-server
        lua-language-server.settings.Lua = {
          workspace.library = [
            "${pkgs.unstable.hyprland}/share/hypr/stubs"
          ];
          diagnostics.global = [ "hl" ];
        };
      };

      diagnostics.inline.enabled = true;

      # Окна и раскладка
      search.button = false;
      debugger.button = false;

      title_bar = {
        show_worktree_name = false;
        show_sign_in = false;
      };

      tabs = {
        git_status = true;
        file_icons = true;
        show_diagnostics = "errors";
      };

      tab_bar = {
        show_nav_history_buttons = true;
      };

      # Панели
      collaboration_panel.button = false;

      # Терминал
      terminal = {
        font_family = "JetBrainsMono Nerd Font Mono";
        font_size = 14;
      };

      # Git
      git = {
        inline_blame.location = "status_bar";
      };

      # ИИ
      disable_ai = true;
    };
  };
}
