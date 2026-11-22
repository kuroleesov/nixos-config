# Системные пакеты: доступны всем пользователям и root. Программы с настройками — в home/ (programs.<имя>)
{ pkgs, ... }:

{
  # v2rayN иначе хранит ядра и настройки рядом с бинарником в /nix/store (read-only)
  environment.sessionVariables.V2RAYN_LOCAL_APPLICATION_DATA_V2 = "1";

  environment.systemPackages = with pkgs; [
    # консольные утилиты
    neovim
    vim
    wget
    curl
    git
    fastfetch
    sl
    cmatrix
    nodejs
    python3 # для простых скриптов и агентов
    python3Packages.pip
    unstable.claude-code
    ffmpeg
    rsync
    lsof # открытые файлы
    psmisc # killall, pstree, fuser
    file # тип файла
    btop # монитор ресурсов

    # сеть
    nmap
    traceroute
    uxplay
    libimobiledevice

    # приложения
    codex
    figma-linux
    mpv
    feishin
    cava
    vscode
    vesktop
    discord-canary
    obs-studio
    ayugram-desktop
    easyeffects
    spotify
    nicotine-plus
    zoom-us
    obsidian
    prismlauncher
    # nixpkgs включил AWS_LC_SYS_USE_SYSTEM=1 для всех Rust-пакетов, а в пакете нет aws-lc; убрать, когда починят в nixpkgs
    (deadlock-mod-manager.overrideAttrs (old: {
      buildInputs = old.buildInputs ++ [ aws-lc ];
    }))
    davinci-resolve

    # железо и диагностика
    opentabletdriver
    pciutils # lspci
    usbutils # lsusb
    parted
    androidenv.androidPkgs.platform-tools # adb и fastboot

    # nix-утилиты
    nix-output-monitor
    nvd
    nix-tree
    nixfmt
    nil

    # архивы
    unzip
    zip
    p7zip
    unrar
  ];
}
