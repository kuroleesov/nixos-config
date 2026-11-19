# CLI-утилиты: beets, fastfetch, gpg, scrcpy, il2cpp-inspector-redux
{ pkgs, ... }:
{
  programs.beets = {
    enable = true;
    settings = {
      library = "~/Music/.beets/beets-library.db";
      directory = "~/Music/Library";

      import = {
        copy = true;
        move = false;
        write = true;
        timid = true; # спрашивать подтверждение
        resume = "ask";
        log = "~/Music/.beets/beets.log";
        languages = [
          "ru"
          "en"
          "ja"
        ];
      };

      paths = {
        # пример: goreshit/2015 - tomboyish love for soda pop and apple sweets digipak/01 - ima, ai ni yukimasu
        default = "$albumartist/$year - $album%aunique{}/$track - $title";
        singleton = "$artist/$year - $title/$track - $title"; # для одиночных треков
        comp = "Compilations/$year - $album%aunique{}/$track - $artist - $title";
      };
    };
  };

  # конфиг генерирует Noctalia из шаблона, см. home/desktop/noctalia/theme.nix
  programs.fastfetch.enable = true;

  programs.gpg.enable = true;

  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-qt;
  };

  home.packages = [
    pkgs.scrcpy
    pkgs.il2cpp-inspector-redux
  ];

  # собственные .desktop-файлы scrcpy не нужны, прячем их из меню
  xdg.dataFile = {
    "applications/scrcpy.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=scrcpy
      Hidden=true
    '';
    "applications/scrcpy-console.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=scrcpy console
      Hidden=true
    '';
  };
}
