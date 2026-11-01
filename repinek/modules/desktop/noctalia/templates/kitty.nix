{
  pkgs,
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.modules.desktop.noctalia.user.enable {
    # Встроенный шаблон kitty правит kitty.conf, а это симлинк Home Manager, поэтому свой шаблон без apply.sh; подключение темы в home/kitty.nix
    programs.noctalia.settings.theme.templates.user.kitty = {
      input_path = "templates/kitty.conf";
      output_path = "~/.config/kitty/themes/noctalia.conf";
    };

    xdg.configFile."noctalia/templates/kitty.conf".source =
      "${pkgs.noctalia}/share/noctalia/assets/templates/kitty/kitty.conf";
  };
}
