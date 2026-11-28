# Fish (vi-режим, функции, приветствие) и bash
{
  programs.fish = {
    enable = true;

    # zsh из-за EDITOR=nvim работал в vi-режиме: Esc — командный режим
    interactiveShellInit = ''
      set -g fish_key_bindings fish_vi_key_bindings

      # личное (серверы, адреса) — в ~/nixos-config/private/*.fish: папка в .gitignore и в репозиторий не попадает
      for f in ~/nixos-config/private/*.fish
          source $f
      end
    '';

    # alias не подходит: fish не принимает функцию с именем «-»
    shellAbbrs."-" = "cd -";

    functions = {
      # Приветствие — fastfetch
      fish_greeting = "fastfetch";

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

      # omp всегда стартует в ~/Projects; папка самого терминала не меняется
      omp = "env -C ~/Projects omp $argv";
    };
  };

  # Функция tl — перевод через локальный LibreTranslate
  xdg.configFile."fish/functions/tl.fish".source = ./tl.fish;

  programs.bash = {
    enable = true;
    enableCompletion = true;
  };
}
