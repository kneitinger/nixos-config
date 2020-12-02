# Installs microcode, modules, etc for AMD CPUs

{ config, pkgs, ... }:

{
  hardware.cpu.amd.updateMicrocode = true;
  boot.kernelModules = [ "kvm-amd" ];
}
