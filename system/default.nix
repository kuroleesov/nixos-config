# Общие модули NixOS для всех машин
{
  imports = [
    ./nix.nix
    ./boot.nix
    ./locale.nix
    ./users.nix
    ./desktop.nix
    ./fonts.nix
    ./audio.nix
    ./network.nix
    ./games.nix
    ./apps.nix
    ./packages.nix
    ./shell.nix
    ./compat.nix
  ];
}
