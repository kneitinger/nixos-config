# Installs the bare minimum system utilities and settings I prefer

{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    (neovim.override {withPython3 = true;})
    file
    git
    htop
    killall
    ripgrep
    python3
    tmux
    tree
    wget
  ];

  services.openssh = {
    enable = true;
  };

  environment.shellAliases = {
    ll = "ls -lah";
    la = "ls -a";
    vim = "nvim";
  };
}
