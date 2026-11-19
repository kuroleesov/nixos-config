{ pkgs, lib, inputs, user, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nix.nix
    ../../modules/nvidia.nix
    ../../modules/desktop.nix
    ../../modules/packages.nix
    ../../modules/disks.nix
    ./repinek.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;
  # ядро 7.x из unstable: там NVIDIA 595.104 собирается под 7.2
  boot.kernelPackages = pkgs.unstable.linuxPackages_latest;

  # Дерево systemd-юнитов на tty12 при загрузке и выключении; отдаёт консоль ly
  services.bootvine.enable = true;
  # иначе сообщения ядра до старта bootvine лезут на экран
  boot.consoleLogLevel = 3;

  # Консоль (ly, bootvine) только на DP-2 в 2560x1440: с HDMI она ужимается до 1920x1080 на обоих.
  # video=…:d гасит HDMI-A-1 и для Hyprland, поэтому на время входа пользователя он включается обратно
  boot.kernelParams = [ "video=HDMI-A-1:d" ];
  systemd.services.hdmi-for-session = {
    description = "Enable HDMI-A-1 while the user is logged in";
    # shortcut: uid 1000 зашит, при смене uid пользователя поправить
    wantedBy = [ "user@1000.service" ];
    partOf = [ "user@1000.service" ];
    before = [ "user@1000.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = "echo detect > /sys/class/drm/card*-HDMI-A-1/status";
    preStop = "echo off > /sys/class/drm/card*-HDMI-A-1/status";
  };

  # Network
  networking.hostName = "pc-1";
  networking.networkmanager.enable = true;
  # строгий rpfilter дропал UDP-ответы из throne-tun (VPN) → не работал войс Discord
  networking.firewall.checkReversePath = "loose";

  # UxPlay (AirPlay): нужен avahi для DNS-SD; порты фиксируются флагом `uxplay -p`
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true; # UDP 5353
    settings.publish = {
      "disable-publishing" = false;
      "disable-user-service-publishing" = false;
      "publish-addresses" = true;
    };
  };
  networking.firewall.allowedTCPPorts = [ 7000 7001 7100 ];
  networking.firewall.allowedUDPPorts = [ 6000 6001 7011 ];

  # avahi пишет pid-файл раньше, чем ставит обработчик SIGHUP; хук openresolv шлёт HUP при старте resolvconf.service → avahi молча умирает и оставляет /run/avahi-daemon/pid
  systemd.services.avahi-daemon.after = [ "resolvconf.service" ];
  # без CAP_DAC_OVERRIDE (hardening nixpkgs) root не может удалить устаревший pid в каталоге avahi:avahi 0755 → «Failed to create PID file»; «+» запускает rm без песочницы
  systemd.services.avahi-daemon.serviceConfig.ExecStartPre = "+${pkgs.coreutils}/bin/rm -f /run/avahi-daemon/pid";

  # Time and locale
  time.timeZone = "Europe/Moscow";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ru_RU.UTF-8";
    LC_IDENTIFICATION = "ru_RU.UTF-8";
    LC_MEASUREMENT = "ru_RU.UTF-8";
    LC_MONETARY = "ru_RU.UTF-8";
    LC_NAME = "ru_RU.UTF-8";
    LC_NUMERIC = "ru_RU.UTF-8";
    LC_PAPER = "ru_RU.UTF-8";
    LC_TELEPHONE = "ru_RU.UTF-8";
    LC_TIME = "ru_RU.UTF-8";
  };
  console.keyMap = "us";

  # Printing
  services.printing.enable = true;

  # Sound: pipewire
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # качество: PipeWire сам переключает частоту под трек (без ресемплинга),
    # а когда ресемплинг неизбежен — лучший алгоритм
    extraConfig.pipewire."10-quality" = {
      "context.properties" = {
        "default.clock.rate" = 48000;
        "default.clock.allowed-rates" = [ 44100 48000 88200 96000 176400 192000 ];
      };
    };
    extraConfig.pipewire-pulse."10-quality" = {
      "stream.properties"."resample.quality" = 10;
    };
    extraConfig.client."10-quality" = {
      "stream.properties"."resample.quality" = 10;
    };
  };

  # Bluetooth (управляется из Noctalia)
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  virtualisation.virtualbox.host.enable = true;

  # User
  users.users.${user} = {
    isNormalUser = true;
    description = "k";
    shell = pkgs.fish;
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "audio"
      "input"
      "kvm"
      "vboxusers"
    ];
  };

  # Programs
  programs.firefox = {
    enable = true;
    languagePacks = [ "en-GB" "ru" ];

    # Дополнения из LibreWolf, которых не было в Firefox. Профиль не трогаем: ставятся при запуске, дальше обновляются сами
    policies.ExtensionSettings = lib.listToAttrs (map (addon: lib.nameValuePair addon.addonId {
      installation_mode = "normal_installed";
      install_url = "file://${addon}/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}/${addon.addonId}.xpi";
    }) (with inputs.firefox-addons.packages.x86_64-linux; [
      vimium
      darkreader
      proton-pass
      refined-github
      pywalfox
      sidebery
    ]));

    # Хост Pywalfox встроен в Noctalia; `noctalia firefox-theme install` прибил бы манифест к старому пути в /nix/store
    nativeMessagingHosts.packages = [
      (pkgs.writeTextDir "lib/mozilla/native-messaging-hosts/pywalfox.json" (builtins.toJSON {
        name = "pywalfox";
        description = "Noctalia Firefox theme native messaging host";
        path = "${pkgs.noctalia}/bin/.noctalia-wrapped";
        type = "stdio";
        allowed_extensions = [ "pywalfox@frewacom.org" ];
      }))
    ];
  };

  programs.throne = {
    enable = true;
    tunMode.enable = true;
  };

  programs.claude-desktop.enable = true;

  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };
  programs.gamemode.enable = true; # в параметрах запуска игры: gamemoderun %command%

  programs.thunar.enable = true;
  programs.thunar.plugins = with pkgs; [
    thunar-archive-plugin
    thunar-volman
  ];
  programs.xfconf.enable = true; # Thunar сохраняет настройки
  services.gvfs.enable = true; # корзина, флешки, сеть в Thunar
  services.tumbler.enable = true; # превью картинок в Thunar

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

  # Запуск обычных Linux-бинарников, скачанных не через Nix
  programs.nix-ld.enable = true;

  system.stateVersion = "26.05"; # Не менять
}
