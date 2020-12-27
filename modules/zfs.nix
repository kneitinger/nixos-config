# Configures a system to boot from ZFS with encryption, auto-snapshotting,
# auto-trim.  Sets up docker to use ZFS as its storage backend.

{ config, pkgs, ... }:

{
  boot.supportedFilesystems = ["zfs"];
  boot.zfs.requestEncryptionCredentials = true;

  services.zfs = {
    autoScrub.enable = true;
    autoSnapshot = {
      enable = true;
      frequent = 8; # keep 2 hours of 15-min snapshots
      monthly = 6;  # keep 6 monthly snapshots
    };
    trim.enable = true;
  };

  virtualisation.docker.storageDriver = "zfs";
}
