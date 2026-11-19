# Браузеры: LibreWolf и ungoogled-chromium
{ pkgs, ... }:
{
  imports = [ ./librewolf.nix ];

  home.packages = [ pkgs.ungoogled-chromium ];
}
