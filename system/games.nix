# Игры: Steam и GameMode
{ pkgs, ... }:

{
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    protontricks.enable = true;
    extraPackages = [ pkgs.gamemode ];
  };

  # в параметрах запуска игры: gamemoderun %command%
  programs.gamemode = {
    enable = true;
    settings = {
      general.renice = 10;
      custom = {
        start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
        end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
      };
    };
  };
}
