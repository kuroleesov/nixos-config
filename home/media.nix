# Медиа: плеер fooyin, Krita, LosslessCut, Loupe, Showtime и OBS Studio
{ pkgs, ... }:
{
  home.packages = [
    pkgs.fooyin
    pkgs.krita
    pkgs.losslesscut
    pkgs.loupe
    pkgs.showtime
  ];

  programs.obs-studio.enable = true;
}
