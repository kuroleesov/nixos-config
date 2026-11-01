{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.shell.fish.user;
  shellAliases = import ./fish-aliases.nix;
in {
  options.modules.shell.fish.user.enable = mkEnableOption "Fish config";

  config = mkIf cfg.enable {
    programs.fish = {
      enable = true;

      # home.shellAliases из home/shell.nix тоже попадают в fish; в fish приоритет у этих
      shellAliases = mapAttrs (_: mkForce) shellAliases;

      functions = {
        # Run Fastfetch as the greeting
        fish_greeting = "fastfetch";
      };
    };

    xdg.configFile."fish/functions/tl.fish".source = ./functions/tl.fish;
  };
}
