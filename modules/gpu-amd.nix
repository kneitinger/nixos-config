# Installs OpenGL and Vulkan support for AMD graphics

{ config, pkgs, ... }:

{
  boot.initrd.kernelModules = [ "amdgpu" ];
  services.xserver.videoDrivers = [ "amdgpu" ];

  hardware.opengl = {
    enable = true;
    driSupport = true;
    extraPackages = with pkgs; [
      rocm-opencl-icd
      rocm-opencl-runtime
      amdvlk
    ];
    # Steam 32-bit settings
    driSupport32Bit = true;
    extraPackages32 = 
      with pkgs.pkgsi686Linux; [ libva driversi686Linux.amdvlk ];
  };
  environment.variables.VK_ICD_FILENAMES =
    "/run/opengl-driver/share/vulkan/icd.d/amd_icd64.json";
}
