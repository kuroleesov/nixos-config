# Приложения с системной частью: Firefox, Claude Desktop, Flatpak, VirtualBox, LocalSend, D-Bus-сервисы
{
  pkgs,
  lib,
  inputs,
  ...
}:

{
  programs.firefox = {
    enable = true;
    languagePacks = [
      "en-GB"
      "ru"
    ];

    # Дополнения из LibreWolf, которых не было в Firefox. Профиль не трогаем: ставятся при запуске, дальше обновляются сами
    policies.ExtensionSettings = lib.listToAttrs (
      map
        (
          addon:
          lib.nameValuePair addon.addonId {
            installation_mode = "normal_installed";
            install_url = "file://${addon}/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}/${addon.addonId}.xpi";
          }
        )
        (
          with inputs.firefox-addons.packages.x86_64-linux;
          [
            vimium
            darkreader
            proton-pass
            refined-github
            pywalfox
            sidebery
          ]
        )
    );
  };

  programs.claude-desktop.enable = true;

  # Flatpak + Flathub (приложения ставятся: flatpak install flathub <id>)
  services.flatpak.enable = true;
  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    '';
  };

  virtualisation.virtualbox.host.enable = true;

  programs.localsend = {
    enable = true;
    openFirewall = true;
  };

  # Loupe и Showtime — DBusActivatable, им нужны свои D-Bus-сервисы
  services.dbus.packages = [
    pkgs.loupe
    pkgs.showtime
  ];
}
