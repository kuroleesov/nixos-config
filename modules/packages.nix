{ pkgs, ... }:

{
  # v2rayN иначе хранит ядра и настройки рядом с бинарником в /nix/store (read-only)
  environment.sessionVariables.V2RAYN_LOCAL_APPLICATION_DATA_V2 = "1";

  environment.systemPackages = with pkgs; [
    neovim
    wget
    curl
    git
    fastfetch
    sl
    nmap
    
    mpv
    feishin
    cava
    cmatrix
    vscode
    unstable.claude-code
    nodejs
    vesktop
    discord-canary
    obs-studio
    ayugram-desktop
    easyeffects
    gnome-keyring
    spotify
    nicotine-plus
    zoom-us
    obsidian
    prismlauncher
    uxplay
    localsend
    libimobiledevice
    # nixpkgs включил AWS_LC_SYS_USE_SYSTEM=1 для всех Rust-пакетов, а в пакете нет aws-lc; убрать, когда починят в nixpkgs
    (deadlock-mod-manager.overrideAttrs (old: { buildInputs = old.buildInputs ++ [ aws-lc ]; }))
    traceroute
    davinci-resolve
    opentabletdriver


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
