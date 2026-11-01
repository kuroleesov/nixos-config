{ pkgs, user, ... }:

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
    publish = {
      enable = true;
      userServices = true;
    };
  };
  networking.firewall.allowedTCPPorts = [ 7000 7001 7100 ];
  networking.firewall.allowedUDPPorts = [ 6000 6001 7011 ];

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

  # User
  programs.zsh.enable = true;
  users.users.${user} = {
    isNormalUser = true;
    description = "k";
    shell = pkgs.zsh;
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "audio"
      "input"
      "kvm"
    ];
  };

  # Programs
  programs.firefox.enable = true;

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
