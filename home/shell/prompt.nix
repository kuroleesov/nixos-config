# Промпт starship

{
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
}
