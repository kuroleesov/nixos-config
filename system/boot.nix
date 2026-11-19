# Ядро, загрузка и экран входа (ly)
{ pkgs, ... }:

{
  # ядро 7.x из unstable: там NVIDIA 595.104 собирается под 7.2
  boot.kernelPackages = pkgs.unstable.linuxPackages_latest;

  # Дерево systemd-юнитов на tty12 при загрузке и выключении; отдаёт консоль ly
  services.bootvine.enable = true;
  # иначе сообщения ядра до старта bootvine лезут на экран
  boot.consoleLogLevel = 3;

  services.displayManager.ly = {
    enable = true;
    settings = {
      corner_bottom_left = "";
      clock = "%d/%m %H:%M:%S";

      full_color = true;
      animation = "dur_file";
      dur_file_path = "/etc/ly/blackhole-smooth-240x67.dur";
      session_log = null;

      # яркость регулируется не из ly
      brightness_up_key = null;
      brightness_down_key = null;
    };
  };

  environment.etc."ly/blackhole-smooth-240x67.dur".source = ../assets/ly/blackhole-smooth-240x67.dur;
}
