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

      # Note: these settings apply to all datasets with the property
      # com.sun:auto-snapshot=true.  To o
      frequent = 8; # every 15 mins
      hourly = 24;
      daily = 7;
      weekly = 4;
      monthly = 2;  # keep 6 monthly snapshots
      flags = "--utc";
    };
    trim.enable = true;
  };

  virtualisation.docker.storageDriver = "zfs";
}
