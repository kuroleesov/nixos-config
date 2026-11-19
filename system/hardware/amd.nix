# AMD Radeon, подключается из hosts/<имя>/default.nix
{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # amdgpu грузится в initrd: ранний KMS, без переключения разрешения при старте
  hardware.amdgpu.initrd.enable = true;

  # LACT: разгон, вентиляторы и мониторинг видеокарты
  services.lact.enable = true;
}
