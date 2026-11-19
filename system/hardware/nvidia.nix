# NVIDIA: проприетарный драйвер. Подключается из hosts/<имя>/default.nix, PRIME для ноутбуков задаётся там же
{
  config,
  lib,
  pkgs,
  ...
}:

{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = [ pkgs.nvidia-vaapi-driver ];
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    open = lib.mkDefault true; # открытые модули ядра — рекомендуются для Turing и новее
    nvidiaSettings = true;
    powerManagement.enable = true; # корректный сон/пробуждение на Wayland
    package = lib.mkDefault config.boot.kernelPackages.nvidiaPackages.stable; # старым картам хост ставит legacy
  };

  environment.sessionVariables = lib.mkMerge [
    {
      # Шейдерный кэш NVIDIA: не чистить автоматически и не ограничивать 1 ГБ,
      # иначе шейдеры в Steam перекомпилируются заново
      __GL_SHADER_DISK_CACHE_SKIP_CLEANUP = "1";
      __GL_SHADER_DISK_CACHE_SIZE = "20000000000"; # 20 ГБ
    }
    # с PRIME offload основная видеокарта — встроенная, эти переменные её бы сломали
    (lib.mkIf (!config.hardware.nvidia.prime.offload.enable) {
      LIBVA_DRIVER_NAME = "nvidia";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      NVD_BACKEND = "direct";
    })
  ];

  # LACT — частоты, кулеры и мониторинг видеокарты
  services.lact.enable = true;

  # vainfo и glxinfo для проверки VA-API и OpenGL
  environment.systemPackages = with pkgs; [
    libva-utils
    mesa-demos
  ];
}
