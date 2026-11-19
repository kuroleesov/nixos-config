# Базовая CLI-среда: утилиты, переменные окружения, zoxide, fzf, bat, direnv
{ pkgs, inputs, ... }:

{
  imports = [
    inputs.nix-index-database.homeModules.nix-index
    ./fish.nix
    ./aliases.nix
    ./prompt.nix
    ./git.nix
  ];

  home.packages = with pkgs; [
    fd
    btop
    dust
    duf
    tealdeer
    yazi
    wget
    unstable.fetch
    trashy # корзина в терминале: rmt, rml, rmr, rme (aliases.nix); модуля Home Manager нет
    libnotify
    nixd # Nix LSP
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

  programs.ripgrep.enable = true;
  programs.jq.enable = true;

  # `, cowsay hi` — запустить любую программу без установки; подсказки "command not found"
  programs.nix-index.enable = true;
  programs.nix-index-database.comma.enable = true;
}
