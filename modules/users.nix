# Declares users, groups, etc.

{ config, pkgs, ... }:

{
  users.users.leaf = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "video" "wheel" ];
    shell = pkgs.zsh;
    # Allow login (locally) without password if user does not yet exist
    initialHashedPassword = "";
  };
}
