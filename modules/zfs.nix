# Configures a system to boot from ZFS with encryption, auto-snapshotting,
# auto-trim.  Sets up docker to use ZFS as its storage backend.

{ config, pkgs, ... }:

{
  boot.supportedFilesystems = ["zfs"];
  boot.zfs.requestEncryptionCredentials = true;
  # See https://grahamc.com/blog/nixos-on-zfs
  boot.kernelParams = [ "elevator=none" ];

  services.zfs = {
    autoScrub.enable = true;
    autoSnapshot = {
      enable = true;
      frequent = 8; # keep the latest eight 15-minute snapshots (instead of four)
      monthly = 6;  # keep only six monthly snapshots (instead of twelve)
    };
    trim.enable = true;
  };

  virtualisation.docker.storageDriver = "zfs";
}
