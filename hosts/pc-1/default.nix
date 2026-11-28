# pc-1: i5-12400F (без встроенной графики), RTX 4060, мониторы DP-2 + HDMI-A-1
{ config, user, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disks.nix
    ../../system
    ../../system/hardware/nvidia.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;

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

  # RTX 4060 в простое падает до 210 МГц и разгоняется только через 0.5–1 с,
  # поэтому анимация переключения воркспейсов шла на холодной карте и фризила.
  # Нижняя граница 1000 МГц, верхнюю не ограничиваем; в простое карта ест на несколько ватт больше
  systemd.services.gpu-min-clock = {
    description = "Lock NVIDIA minimum graphics clock";
    wantedBy = [ "multi-user.target" ];
    after = [ "lactd.service" ];
    serviceConfig.Type = "oneshot";
    script = "${config.hardware.nvidia.package.bin}/bin/nvidia-smi --lock-gpu-clocks=1000,3000";
  };
  # shortcut: не проверял, сбрасывает ли сон блокировку частот; переприменяем после пробуждения на всякий случай
  powerManagement.resumeCommands = "systemctl restart --no-block gpu-min-clock.service";

  networking.hostName = "pc-1";

  # Bluetooth (управляется из Noctalia)
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  users.users.${user}.description = "k";

  system.stateVersion = "26.05"; # Не менять
}
