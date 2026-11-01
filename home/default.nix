{ inputs, user, ... }:

{
  imports = [
    inputs.nix-index-database.homeModules.nix-index
    ./shell.nix
    ./kitty.nix
    ./hyprland.nix
  ];

  home.username = user;
  home.homeDirectory = "/home/${user}";

  programs.home-manager.enable = true;

  home.stateVersion = "26.05";
}
