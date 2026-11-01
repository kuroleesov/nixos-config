# софт из repinek/nixos-dotfiles поверх конфига pc-1 (Home Manager)
{ inputs, ... }:

{
  imports = [
    inputs.osu-lazer.homeManagerModules.osu-lazer
    "${inputs.home-manager-unstable}/modules/programs/noctalia"

    ../repinek/modules/cli/beets/user.nix
    ../repinek/modules/cli/fastfetch/user.nix
    ../repinek/modules/cli/gh/user.nix
    ../repinek/modules/cli/gpg/user.nix
    ../repinek/modules/cli/scrcpy/user.nix

    ../repinek/modules/core/packages/user.nix

    ../repinek/modules/desktop/noctalia/user.nix
    ../repinek/modules/desktop/theme/user.nix

    ../repinek/modules/editors/zed/user.nix
    ../repinek/modules/editors/re/il2cpp-inspector-redux/user.nix

    ../repinek/modules/games/osu-lazer/user.nix
    ../repinek/modules/games/steamguard-cli/user.nix
    ../repinek/modules/games/touhou/user.nix

    ../repinek/modules/programs/alacritty/user.nix
    ../repinek/modules/programs/anki/user.nix
    ../repinek/modules/programs/browsers/librewolf/user.nix
    ../repinek/modules/programs/browsers/ungoogled-chromium/user.nix
    ../repinek/modules/programs/filelight/user.nix
    ../repinek/modules/programs/gnome-disk-utility/user.nix
    ../repinek/modules/programs/keepassxc/user.nix
    ../repinek/modules/programs/libreoffice/user.nix
    ../repinek/modules/programs/media/fooyin/user.nix
    ../repinek/modules/programs/media/krita/user.nix
    ../repinek/modules/programs/media/losslesscut/user.nix
    ../repinek/modules/programs/media/loupe/user.nix
    ../repinek/modules/programs/media/obs-studio/user.nix
    ../repinek/modules/programs/media/showtime/user.nix
    ../repinek/modules/programs/messengers/element-desktop/user.nix
    ../repinek/modules/programs/messengers/telegram-desktop/user.nix
    ../repinek/modules/programs/nemo/user.nix
    ../repinek/modules/programs/proton-authenticator/user.nix
    ../repinek/modules/programs/qbittorrent/user.nix

    ../repinek/modules/shell/fish/user.nix
  ];

  modules.cli = {
    beets.user.enable = true;
    fastfetch.user.enable = true;
    gh.user.enable = true;
    gpg.user.enable = true;
    scrcpy.user.enable = true;
  };

  modules.core.packages.user.enable = true;

  modules.desktop = {
    noctalia.user.enable = true;
    theme.user.enable = true;
  };

  modules.editors = {
    re.il2cpp-inspector-redux.user.enable = true;
    zed.user.enable = true;
  };

  modules.games = {
    osu-lazer.user.enable = true;
    steamguard-cli.user.enable = true;
    touhou.user.enable = true;
  };

  modules.programs = {
    alacritty.user.enable = true;
    anki.user.enable = true;
    browsers = {
      librewolf.user.enable = true;
      ungoogled-chromium.user.enable = true;
    };
    filelight.user.enable = true;
    gnome-disk-utility.user.enable = true;
    keepassxc.user.enable = true;
    libreoffice.user.enable = true;
    media = {
      fooyin.user.enable = true;
      krita.user.enable = true;
      losslesscut.user.enable = true;
      loupe.user.enable = true;
      obs-studio.user.enable = true;
      showtime.user.enable = true;
    };
    messengers = {
      element-desktop.user.enable = true;
      telegram-desktop.user.enable = true;
    };
    nemo.user.enable = true;
    proton-authenticator.user.enable = true;
    qbittorrent.user.enable = true;
  };

  modules.shell.fish.user.enable = true;
}
