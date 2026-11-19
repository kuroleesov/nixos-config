_: {
  programs.noctalia.settings.theme = {
    # Catppuccin is the default, but any scheme can be used
    # Change it in settings
    # NOTE: Do not extract the color palette from the wallpaper
    builtin = "Catppuccin";

    # source = "community";
    community_palette = "Lilac AMOLED";
    mode = "dark";

    # See the templates directory as well
    templates = {
      builtin_ids = ["alacritty" "btop" "hyprland" "gtk3" "gtk4" "kcolorscheme" "qt"];
      # Without obsidian and ungoogled-chromium: their templates run unpinned shell hooks on every theme apply
      community_ids = ["pywalfox" "discord" "vscode" "obs" "zed" "codex"];
    };
  };
}
