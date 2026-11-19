# Шрифты и шрифты по умолчанию
{ pkgs, ... }:

let
  # шрифт интерфейса по умолчанию; в nixpkgs его нет
  google-sans-flex = pkgs.runCommand "google-sans-flex" { } ''
    install -Dm444 ${
      pkgs.fetchurl {
        name = "GoogleSansFlex.ttf";
        url = "https://raw.githubusercontent.com/google/fonts/bd8f81ddb5c74d5c8897b36ad88b440266245103/ofl/googlesansflex/GoogleSansFlex%5BROND%2Copsz%2Cslnt%2Cwdth%2Cwght%5D.ttf";
        hash = "sha256-qax3B5iFfV6KxZPO1Csi5Ap8CM7Jgxn5Kw7Mwng6d7o=";
      }
    } $out/share/fonts/truetype/GoogleSansFlex.ttf
  '';
in
{
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      inter
      google-sans-flex
      material-symbols
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      iosevka
      roboto
      plus-jakarta-sans
      corefonts # Microsoft Core Fonts (unfree)
      source-serif-pro
    ];
    fontconfig.defaultFonts = {
      sansSerif = [
        "Google Sans Flex"
        "Inter"
        "Noto Sans"
      ];
      monospace = [ "JetBrainsMono Nerd Font" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };
}
