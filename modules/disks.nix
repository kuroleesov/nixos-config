{ ... }:

# Дополнительные диски. nofail — если диска нет или он не монтируется, система всё равно загрузится.
# x-gvfs-show — диск виден в боковой панели Thunar.
{
  boot.supportedFilesystems = [ "ntfs" ];

  # HDD 1 ТБ (Seagate ST31000528AS), NTFS, метка «НЕ ТРОГАТЬ» — данные, НЕ форматировать.
  # ntfs-3g: если Windows оставила диск «грязным» (быстрый запуск/гибернация),
  # он сам смонтируется только на чтение.
  fileSystems."/mnt/hdd" = {
    device = "/dev/disk/by-uuid/D81EBC6D1EBC4672";
    fsType = "ntfs-3g";
    options = [
      "rw"
      "uid=1000"
      "gid=100"
      "dmask=022"
      "fmask=133"
      "windows_names" # не даёт создавать имена файлов, запрещённые в Windows
      "noatime"
      "nofail"
      "x-systemd.device-timeout=10s"
      "x-gvfs-show"
    ];
  };

  # SSD 240 ГБ (Kingston SHFS37A240G), ext4 с меткой «ssd»
  fileSystems."/mnt/ssd" = {
    device = "/dev/disk/by-label/ssd";
    fsType = "ext4";
    options = [
      "noatime"
      "nofail"
      "x-systemd.device-timeout=10s"
      "x-gvfs-show"
    ];
  };

  services.fstrim.enable = true; # еженедельный TRIM для SSD
}
