# Прикладные программы: Anki, KeePassXC, LibreOffice, мессенджеры, торренты и утилиты
{ pkgs, ... }:
{
  home.packages = [
    pkgs.unstable.libreoffice-qt-stable
    pkgs.kdePackages.filelight
    pkgs.gnome-disk-utility
    pkgs.qbittorrent
    pkgs.proton-authenticator

    (pkgs.symlinkJoin {
      name = "telegram-desktop";
      paths = [ pkgs.telegram-desktop ];
      nativeBuildInputs = [ pkgs.makeWrapper ];

      # явная синхронизация (explicit sync) ломает WebView в Telegram на NVIDIA + Wayland → отключаем её
      # https://github.com/telegramdesktop/tdesktop/issues/31055
      # https://github.com/telegramdesktop/tdesktop/issues/31424
      postBuild = ''
        wrapProgram "$out/bin/Telegram" \
          --set __NV_DISABLE_EXPLICIT_SYNC 1

        service=share/dbus-1/services/org.telegram.desktop.service
        rm "$out/$service"
        substitute "${pkgs.telegram-desktop}/$service" "$out/$service" \
          --replace-fail "${pkgs.telegram-desktop}/bin/Telegram" "$out/bin/Telegram"
      '';
    })
  ];

  programs.anki = {
    enable = true;
    package = pkgs.unstable.anki;

    language = "en_GB";

    reduceMotion = true;
    uiScale = 1.4;

    addons = [
      pkgs.unstable.ankiAddons.review-heatmap
      pkgs.unstable.ankiAddons.crowdanki

      (pkgs.unstable.anki-utils.buildAnkiAddon (finalAttrs: {
        pname = "More_Decks_Stats_and_Time_Left";
        version = "2.9";
        src = pkgs.fetchFromGitHub {
          owner = "cjdduarte";
          repo = "MDS_Time_Left";
          rev = "4964216a1eaf03ec299ec2a3df1379108a9f9116";
          hash = "sha256-6Mi+JdbaabW2brxK8TEs7V+QU7h6EyNCixUcUbM4BOM=";
        };
        sourceRoot = "${finalAttrs.src.name}";
      }))
    ];
  };

  programs.keepassxc.enable = true;

  # при первом запуске Element нужен флаг --password-store=gnome-libsecret
  programs.element-desktop.enable = true;
}
