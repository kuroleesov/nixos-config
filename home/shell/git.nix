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
      # push/pull на GitHub берут вход из gh (gh auth login); пустой helper сбрасывает чужие помощники, как gh auth setup-git
      credential =
        let
          helper = [
            ""
            "!${pkgs.gh}/bin/gh auth git-credential"
          ];
        in
        {
          "https://github.com".helper = helper;
          "https://gist.github.com".helper = helper;
        };
    };
    # имя и почта для коммитов — в ~/nixos-config/private/gitconfig (папка в .gitignore); ~/.config/git/config только для чтения
    includes = [ { path = "~/nixos-config/private/gitconfig"; } ];
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
