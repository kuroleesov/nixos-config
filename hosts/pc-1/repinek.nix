# софт и сервисы из repinek/nixos-dotfiles поверх конфига pc-1
{ pkgs, ... }:

{
  imports = [
    ../../repinek/modules/cli/platform-tools/system.nix

    ../../repinek/modules/core/fonts/system.nix
    ../../repinek/modules/core/packages/system.nix

    ../../repinek/modules/desktop/ly/system.nix

    ../../repinek/modules/games/gamemode/system.nix
    ../../repinek/modules/games/steam/system.nix

    ../../repinek/modules/programs/localsend/system.nix
    ../../repinek/modules/programs/media/loupe/system.nix
    ../../repinek/modules/programs/media/showtime/system.nix

    ../../repinek/modules/shell/fish/system.nix
  ];

  modules.cli.platform-tools.system.enable = true;

  modules.core = {
    fonts.system.enable = true;
    packages.system.enable = true;
  };

  modules.desktop.ly.system = {
    enable = true;
    remove_brightness_keys = true;
  };

  modules.games = {
    gamemode.system.enable = true;
    steam.system.enable = true;
  };

  modules.programs = {
    localsend.system.enable = true;
    media = {
      loupe.system.enable = true;
      showtime.system.enable = true;
    };
  };

  modules.shell.fish.system.enable = true;

  services.lact.enable = true;

  environment.systemPackages = with pkgs; [ libva-utils mesa-demos ];
}
