# Home Manager: всё, что лежит в домашней папке пользователя (~/.config и пакеты пользователя)
{ user, osConfig, ... }:

{
  imports = [
    ./shell
    ./desktop
    ./terminals.nix
    ./editors.nix
    ./browsers
    ./apps.nix
    ./media.nix
    ./games.nix
    ./cli.nix
  ];

  home.username = user;
  home.homeDirectory = "/home/${user}";

  programs.home-manager.enable = true;

  # Как у системы: на новом компьютере install.sh ставит версию NixOS на момент установки
  home.stateVersion = osConfig.system.stateVersion;
}
