# Intel iGPU, подключается из hosts/<имя>/default.nix
{ pkgs, ... }:
{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = [ pkgs.intel-media-driver ];
  };

  # VA-API для Broadwell и новее
  environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";
}
