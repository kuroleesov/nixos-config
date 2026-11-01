{ config, pkgs, ... }:

# RTX 40xx (AD107). У i5-12400F нет встроенной графики, так что это единственная видеокарта.
{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = [ pkgs.nvidia-vaapi-driver ];
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    open = true; # открытые модули ядра — рекомендуются для Turing и новее
    nvidiaSettings = true;
    powerManagement.enable = true; # корректный сон/пробуждение на Wayland
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    NVD_BACKEND = "direct";
    NIXOS_OZONE_WL = "1"; # Electron/Chromium (VSCode и т.п.) нативно на Wayland

    # Шейдерный кэш NVIDIA: не чистить автоматически и не ограничивать 1 ГБ,
    # иначе шейдеры в Steam перекомпилируются заново
    __GL_SHADER_DISK_CACHE_SKIP_CLEANUP = "1";
    __GL_SHADER_DISK_CACHE_SIZE = "20000000000"; # 20 ГБ
  };
}
