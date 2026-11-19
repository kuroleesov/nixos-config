# Fish как системная оболочка
{
  programs.fish = {
    enable = true;

    # Home Manager переопределяет эти настройки для пользователей, но для root они остаются
    shellAliases = {
      "ls" = "ls -la";
    };

    interactiveShellInit = ''
      set -g fish_greeting
    '';
  };
}
