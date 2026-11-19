# Git, delta и инструменты GitHub
{ pkgs, ... }:

{
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

  # gh только пакетом: programs.gh перезаписал бы ~/.config/gh/config.yml
  home.packages = with pkgs; [
    gh
    lazygit
  ];
}
