{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    neovim
    wget
    curl
    git
    fastfetch
    sl
    amnezia-vpn
    mpv
    cava # раньше приходил вместе с Dux
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
    nicotine-plus
    gapless
    zoom-us
    obsidian
    prismlauncher
    uxplay
    localsend
    libimobiledevice


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
