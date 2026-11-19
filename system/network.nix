# Сеть: NetworkManager, файрвол, avahi (UxPlay), Throne (VPN)
{ pkgs, ... }:

{
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
  # порты UxPlay
  networking.firewall.allowedTCPPorts = [
    7000
    7001
    7100
  ];
  networking.firewall.allowedUDPPorts = [
    6000
    6001
    7011
  ];

  # avahi пишет pid-файл раньше, чем ставит обработчик SIGHUP; хук openresolv шлёт HUP при старте resolvconf.service → avahi молча умирает и оставляет /run/avahi-daemon/pid
  systemd.services.avahi-daemon.after = [ "resolvconf.service" ];
  # без CAP_DAC_OVERRIDE (hardening nixpkgs) root не может удалить устаревший pid в каталоге avahi:avahi 0755 → «Failed to create PID file»; «+» запускает rm без песочницы
  systemd.services.avahi-daemon.serviceConfig.ExecStartPre =
    "+${pkgs.coreutils}/bin/rm -f /run/avahi-daemon/pid";

  programs.throne = {
    enable = true;
    tunMode.enable = true;
  };
}
