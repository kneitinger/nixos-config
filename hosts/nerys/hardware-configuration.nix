# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules =
    [ "nvme" "xhci_pci" "usbhid" "usb_storage" "sd_mod" "sdhci_pci"
    ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];
  boot.initrd.luks.devices.cryptroot =
    { device = "/dev/disk/by-uuid/a7f22a4f-94ab-4d0c-8d45-2c0fc943b148";
    };

  fileSystems."/" =
    { device = "rpool/NIXOS/system/root";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/F650-4CF2";
      fsType = "vfat";
    };

  fileSystems."/var" =
    { device = "rpool/NIXOS/system/var";
      fsType = "zfs";
    };

  fileSystems."/nix" =
    { device = "rpool/NIXOS/local/nix";
      fsType = "zfs";
    };

  fileSystems."/home/leaf" =
    { device = "rpool/NIXOS/home/leaf";
      fsType = "zfs";
    };

  fileSystems."/home/leaf/art" =
    { device = "rpool/DATA/art";
      fsType = "zfs";
    };

  fileSystems."/home/leaf/music" =
    { device = "rpool/DATA/music";
      fsType = "zfs";
    };

  fileSystems."/home/leaf/r" =
    { device = "rpool/DATA/code";
      fsType = "zfs";
    };

  fileSystems."/home/leaf/downloads" =
    { device = "rpool/DATA/downloads";
      fsType = "zfs";
    };

  fileSystems."/home/leaf/documents" =
    { device = "rpool/DATA/documents";
      fsType = "zfs";
    };

  swapDevices = [ ];
}
