# Совместимость со сторонними бинарниками: nix-ld, AppImage, FHS-пути /usr/share/*
# (адаптировано из github.com/deadinside28/nixos-config)
{ pkgs, ... }:

let
  # resolve-symlinks: в /run/current-system/sw/share симлинки в стор, а чужой софт по ним не ходит;
  # nofail: пустой источник не уронит загрузку в emergency
  bindfsOptions = [
    "ro"
    "nofail"
    "x-gvfs-hide"
    "resolve-symlinks"
  ];
in
{
  # Запуск обычных Linux-бинарников, скачанных не через Nix.
  # Падает с `error while loading shared libraries: libX.so` → `nix-locate libX.so`, дописать пакет сюда
  # (NIX_LD_LIBRARY_PATH подхватывается при перезаходе в сессию)
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      # база
      stdenv.cc.cc.lib
      glibc
      zlib
      openssl
      fuse # рантайм AppImage (libfuse.so.2)
      fuse3
      icu
      libuuid
      libxml2
      libsecret
      harfbuzz
      freetype
      fontconfig
      fribidi
      libgcrypt
      libgpg-error
      keyutils.lib
      curl

      # графика и UI
      mesa
      libgbm # Electron/Chromium: libgbm.so.1
      libGL
      libGLU
      libepoxy
      libdrm
      libva
      vulkan-loader
      gtk3
      gtk4
      libadwaita
      pango
      cairo
      atk
      at-spi2-atk
      gdk-pixbuf
      glib
      pciutils

      # X11 и Wayland
      wayland
      libX11
      libXext
      libXrender
      libXfixes
      libXcomposite
      libXdamage
      libXcursor
      libXi
      libXrandr
      libXScrnSaver
      libXtst
      libxcb
      libxkbcommon
      libsm
      libice

      # xcb-хелперы для Qt-плагина xcb («Could not load the Qt platform plugin xcb»).
      # Сам Qt не класть: образы несут свой, хостовый даст конфликт версий
      libxcb-util
      libxcb-wm
      libxcb-image
      libxcb-keysyms
      libxcb-render-util
      libxcb-cursor

      # звук и медиа
      alsa-lib
      libpulseaudio
      pipewire
      cups
      ffmpeg
      openal
      libjack2
      sndio
      SDL2

      # Electron
      nss
      nspr
      expat
      dbus
      at-spi2-core

      # ввод и легаси-стек эмуляторов
      libevdev
      e2fsprogs
      libedit
      libpng
      libjpeg
      libtiff

      # математика и сжатие
      gmp
      nettle
      libtasn1
      p11-kit
      bzip2
      xz
      zstd
      brotli
      libffi

      # прочее
      udev
      libnotify
    ];
  };

  # setuid-обёртки fusermount: без них AppImage не смонтирует сам себя
  programs.fuse.enable = true;

  # виртуальные /usr/bin и /bin из PATH — для софта с захардкоженными путями
  services.envfs.enable = true;

  # Шим appimage-run: образ исполняется сам (загрузчик — nix-ld), шим только направляет
  # диалоги выбора файлов в портал. Через него идут ярлыки из меню Nemo (home/desktop/nemo-appimage.nix)
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "appimage-run" ''
      if [ $# -eq 0 ]; then
        echo "usage: appimage-run <образ.AppImage> [аргументы]" >&2
        exit 1
      fi

      img="$1"
      shift

      if [ ! -f "$img" ]; then
        echo "appimage-run: файл не найден: $img" >&2
        exit 1
      fi

      [ -x "$img" ] || chmod +x "$img" 2>/dev/null || true

      export QT_QPA_PLATFORMTHEME=xdgdesktopportal
      export GTK_USE_PORTAL=1
      export GDK_DEBUG=portals

      exec "$img" "$@"
    '')
  ];

  # Шрифты, иконки и темы по FHS-путям: AppImage, Steam-игры, Wine ищут их ровно в /usr/share/*
  fonts.fontDir.enable = true; # источник для /usr/share/fonts
  system.fsPackages = [ pkgs.bindfs ];
  fileSystems = {
    "/usr/share/fonts" = {
      device = "/run/current-system/sw/share/X11/fonts";
      fsType = "fuse.bindfs";
      options = bindfsOptions;
    };
    "/usr/share/icons" = {
      device = "/run/current-system/sw/share/icons";
      fsType = "fuse.bindfs";
      options = bindfsOptions;
    };
    "/usr/share/themes" = {
      device = "/run/current-system/sw/share/themes";
      fsType = "fuse.bindfs";
      options = bindfsOptions;
    };
  };
}
