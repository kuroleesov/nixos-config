{ pkgs, ... }:

let
  flake = "~/nixos-config";
in
{
  home.packages = with pkgs; [
    ripgrep
    fd
    jq
    btop
    dust
    duf 
    tealdeer
    lazygit
    yazi
    wget
    unstable.fetch
  ];

  # Поля и вид для fetch; логотип берётся из fastfetch по дистрибутиву
  xdg.configFile."fetch/config".text = ''
    os
    kernel
    uptime
    packages
    shell
    display
    wm
    terminal
    cpu
    gpu
    memory
    disk
    colors

    label_color=blue
    box=1
    shading_mode=sextants
  '';

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    MANPAGER = "sh -c 'col -bx | bat -l man -p'";
  };

  # uv, claude и прочие пользовательские бинари
  home.sessionPath = [ "$HOME/.local/bin" ];

  # Алиасы общие для fish и bash
  home.shellAliases = {
    # --- NixOS ---
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
    nrepl = "nix repl --expr 'import <nixpkgs> {}'";
    nsh = "nix-shell --run fish -p"; # nsh htop cowsay — временное окружение
    nr = "nix run nixpkgs#"; # nr hello — запустить без установки (без пробела!)

    # --- ls / cat / навигация ---
    ls = "eza --icons --group-directories-first";
    l = "eza -l --icons --git --group-directories-first";
    ll = "eza -lah --icons --git --group-directories-first";
    la = "eza -a --icons --group-directories-first";
    lt = "eza --tree --level=2 --icons";
    tree = "eza --tree --icons";
    cat = "bat --paging=never";
    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";

    # --- безопаснее по умолчанию ---
    cp = "cp -iv";
    mv = "mv -iv";
    rm = "rm -Iv";
    mkdir = "mkdir -pv";

    # --- система ---
    top = "btop";
    ports = "ss -tulpn";
    myip = "curl -s ifconfig.me && echo";
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
    hconf = "$EDITOR ${flake}/home/hypr/hyprland.lua";
    clients = "hyprctl clients";
  };

  programs.fish = {
    enable = true;

    # zsh из-за EDITOR=nvim работал в vi-режиме: Esc — командный режим
    interactiveShellInit = ''
      set -g fish_key_bindings fish_vi_key_bindings
    '';

    # alias не подходит: fish не принимает функцию с именем «-»
    shellAbbrs."-" = "cd -";

    functions = {
      # Клавиши из zsh, которых нет в fish из коробки
      fish_user_key_bindings = ''
        for mode in default insert
            # Ctrl+D: на пустой строке выход, иначе список вариантов
            bind -M $mode ctrl-d 'if test -n "$(commandline)"; commandline -f complete; else; commandline -f exit; end'
            bind -M $mode ctrl-g complete
        end

        bind -M insert ctrl-w backward-kill-word
        bind -M insert alt-/ history-token-search-backward
        bind -M insert alt-comma history-token-search-forward

        bind -M default ctrl-p up-or-search
        bind -M default ctrl-n down-or-search
        bind -M default n up-or-search
        bind -M default N down-or-search
        bind -M default -- - up-or-search
        bind -M default + down-or-search
        bind -M default space forward-char
        bind -M default = complete
        bind -M default -m insert \? history-pager repaint-mode
        bind -M default -m visual V beginning-of-line begin-selection end-of-line repaint-mode
      '';

      # mkcd dir — создать папку и перейти в неё
      mkcd = "mkdir -p $argv[1]; and cd $argv[1]";

      # extract file — распаковать любой архив
      extract = ''
        switch "$argv[1]"
            case '*.tar.bz2' '*.tbz2'
                tar xjf $argv[1]
            case '*.tar.gz' '*.tgz'
                tar xzf $argv[1]
            case '*.tar.xz'
                tar xJf $argv[1]
            case '*.tar.zst'
                tar --zstd -xf $argv[1]
            case '*.tar'
                tar xf $argv[1]
            case '*.bz2'
                bunzip2 $argv[1]
            case '*.gz'
                gunzip $argv[1]
            case '*.zip'
                unzip $argv[1]
            case '*.rar'
                unrar x $argv[1]
            case '*.7z'
                7z x $argv[1]
            case '*'
                echo "extract: не знаю, как распаковать '$argv[1]'"
        end
      '';

      # cheat cmd — шпаргалка по команде
      cheat = ''curl -s "cheat.sh/$argv[1]"'';

      # vps — туннель к панели 3x-ui на NL VPS и открыть её в браузере (Ctrl+C закрывает)
      vps = ''
        set -l url http://localhost:24001/<panel-path>
        echo "Панель открыта"
        echo "панель: $url  (Ctrl+C — закрыть туннель)"
        # браузер открываем, как только туннель начал отвечать
        fish -c "for i in (seq 40); curl -s -o /dev/null $url; and exec xdg-open $url >/dev/null 2>&1; sleep 0.5; end" &
        disown
        ssh -N -o ExitOnForwardFailure=yes -L 24001:127.0.0.1:24001 root@<vps-ip>
      '';
    };
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
  };

  # Красивый быстрый промпт: «таблетки» в цветах палитры терминала (kitty)
  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      command_timeout = 1000;

      format = "$username$hostname$directory$git_branch$git_status$nix_shell$python$rust$nodejs$golang$cmd_duration$line_break$character";
      right_format = "$time";

      username = {
        show_always = false;
        format = "[](fg:red)[ $user ](bg:red fg:black)[](fg:red) ";
      };
      hostname = {
        ssh_only = true;
        format = "[](fg:red)[ $hostname ](bg:red fg:black)[](fg:red) ";
      };
      directory = {
        format = "[](fg:blue)[  $path$read_only ](bg:blue fg:black)[](fg:blue) ";
        truncation_length = 3;
        truncation_symbol = "…/";
        read_only = " 🔒";
      };
      git_branch = {
        format = "[](fg:purple)[  $branch ](bg:purple fg:black)[](fg:purple) ";
      };
      git_status = {
        format = "[](fg:yellow)[ $all_status$ahead_behind ](bg:yellow fg:black)[](fg:yellow) ";
        conflicted = "=";
        ahead = "⇡$count";
        behind = "⇣$count";
        diverged = "⇕";
        untracked = "?$count";
        stashed = "$";
        modified = "!$count";
        staged = "+$count";
        deleted = "✘$count";
      };
      nix_shell = {
        format = "[](fg:cyan)[  $state ](bg:cyan fg:black)[](fg:cyan) ";
      };
      python = {
        format = "[](fg:green)[ 🐍 $version ](bg:green fg:black)[](fg:green) ";
      };
      rust = {
        format = "[](fg:green)[ 🦀 $version ](bg:green fg:black)[](fg:green) ";
      };
      nodejs = {
        format = "[](fg:green)[ ⬢ $version ](bg:green fg:black)[](fg:green) ";
      };
      golang = {
        format = "[](fg:green)[ 🐹 $version ](bg:green fg:black)[](fg:green) ";
      };
      cmd_duration = {
        min_time = 2000;
        format = "[](fg:red)[ ⏱ $duration ](bg:red fg:black)[](fg:red) ";
      };
      time = {
        disabled = false;
        time_format = "%H:%M";
        format = "[ $time ](dimmed)";
      };
      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
        vimcmd_symbol = "[❮](bold purple)";
      };
    };
  };

  # z <часть пути> — умный cd по истории; zi — интерактивный выбор
  programs.zoxide.enable = true;

  # Ctrl+R — поиск по истории, Ctrl+T — поиск файла, Alt+C — cd в папку
  programs.fzf = {
    enable = true;
    defaultCommand = "fd --type f --hidden --exclude .git";
    fileWidget.command = "fd --type f --hidden --exclude .git";
    changeDirWidget.command = "fd --type d --hidden --exclude .git";
  };

  programs.eza.enable = true;
  programs.bat = {
    enable = true;
    config.theme = "ansi";
  };

  # direnv + nix-direnv: `use flake` в .envrc — окружение проекта поднимается само при cd
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    silent = true;
  };

  # `, cowsay hi` — запустить любую программу без установки; подсказки "command not found"
  programs.nix-index.enable = true;
  programs.nix-index-database.comma.enable = true;

  programs.git = {
    enable = true;
    settings = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      rerere.enabled = true;
      alias = {
        st = "status -sb";
        last = "log -1 HEAD --stat";
        undo = "reset --soft HEAD~1";
      };
    };
  };
  programs.delta = {
    enable = true; # красивые git diff
    enableGitIntegration = true;
    options = {
      navigate = true;
      line-numbers = true;
    };
  };

}
