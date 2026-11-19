# Алиасы, общие для fish и bash
{ ... }:

let
  flake = "~/nixos-config";
in
{
  home.shellAliases = {
    btw = "echo I use NixOS, btw";

    # --- nh и NixOS ---
    rebuild = "nh os switch"; # пересобрать и применить
    rbt = "nh os test"; # применить без записи в загрузчик
    rbb = "nh os boot"; # применить после перезагрузки
    upd = "nh os switch --update"; # обновить flake.lock + пересобрать
    nclean = "nh clean all --keep 5 --keep-since 7d"; # чистка старых поколений
    ns = "nh search"; # поиск пакетов
    nconf = "cd ${flake} && $EDITOR .";
    ncode = "code ${flake}";
    ngens = "nixos-rebuild list-generations";
    ndiff = "nvd diff $(command ls -d1v /nix/var/nix/profiles/system-*-link | tail -2)"; # что поменялось в последнем rebuild
    nfmt = "nix fmt ${flake}";
    # без #хост: nixos-rebuild берёт конфигурацию по имени компьютера
    nixos-switch = "sudo nixos-rebuild switch --flake ${flake}";
    nixos-test = "sudo nixos-rebuild test --flake ${flake}";
    nixos-vm = "sudo nixos-rebuild build-vm --flake ${flake}";

    # --- nix ---
    nrepl = "nix repl --expr 'import <nixpkgs> {}'";
    nsh = "nix-shell --run fish -p"; # nsh htop cowsay — временное окружение
    nr = "nix run nixpkgs#"; # nr hello — запустить без установки (без пробела!)
    nix-update = "nix flake update";
    nix-search = "nix search nixpkgs";
    nix-gc = "sudo nix-store --gc";

    # --- навигация и файлы ---
    dt = "cd ${flake}";
    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";
    "....." = "cd ../../../..";
    cp = "cp -iv";
    mv = "mv -iv";
    rm = "rm -Iv";
    mkdir = "mkdir -p";
    wget = "wget -c";
    untar = "tar -axvf";
    tarnow = "tar -acf";
    exp = "nemo -t $PWD"; # открыть Nemo в текущей папке

    # --- eza и bat: a = все файлы, l = подробно ---
    ls = "eza -al --color=auto --group-directories-first --icons=auto";
    l = "eza -l --icons --git --group-directories-first";
    ll = "eza -lah --icons --git --group-directories-first";
    la = "eza -a  --color=auto --group-directories-first --icons=auto";
    lla = "eza -la";
    lt = "eza -aT --color=auto --group-directories-first --icons=auto";
    ld = "eza -a  --color=never | rg '^\\.'";
    tree = "lt";
    cat = "bat --paging=never --wrap=never --plain";

    # --- корзина (trashy) вместо немедленного удаления ---
    rmt = "trash";
    rml = "trash list";
    rmr = "trash restore";
    rme = "trash empty";

    # --- ripgrep ---
    rgi = "rg --ignore-case";
    rgl = "rg --files-with-matches";

    # --- система ---
    top = "btop";
    ports = "ss -tulpn";
    myip = "curl api.ipify.org";
    weather = "curl -s 'wttr.in/?lang=ru&M'";
    sctl = "systemctl";
    uctl = "systemctl --user";
    jctl = "journalctl -xe";
    jfu = "journalctl --user -f -u";
    grep = "grep --color=auto";
    c = "clear";
    h = "history";
    q = "exit";
    v = "nvim";
    y = "yazi";
    ff = "fastfetch";
    please = "sudo";

    # --- git ---
    g = "git";
    gs = "git status -sb";
    ga = "git add";
    gaa = "git add -A";
    gc = "git commit -m";
    gca = "git commit --amend --no-edit";
    gp = "git push";
    gpl = "git pull --rebase";
    gd = "git diff";
    gds = "git diff --staged";
    gl = "git log --oneline --graph --decorate -20";
    gco = "git checkout";
    gsw = "git switch";
    gb = "git branch";
    lg = "lazygit";

    # --- Hyprland ---
    hr = "hyprctl reload";
    hconf = "$EDITOR ${flake}/home/desktop/hypr/hyprland.lua";
    clients = "hyprctl clients";

    # --- kitty ---
    kssh = "kitten ssh"; # ssh, который сам копирует terminfo kitty на сервер
    icat = "kitten icat"; # показать картинку прямо в терминале
    kdiff = "kitten diff"; # diff с подсветкой и картинками
  };
}
