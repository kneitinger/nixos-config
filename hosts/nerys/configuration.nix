{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules/minimum.nix
      ../../modules/audio.nix
      ../../modules/cpu-amd.nix
      ../../modules/gpu-amd.nix
      ../../modules/users.nix
      ../../modules/zfs.nix

      # Use NixOS/nixos-hardware for laptop specific settings
      #    Kernel > 5.8, acpi_backlight=native kernel param, acpi_call module,
      #    trackpoint enable & trackpoint emulate_wheel, tlp enable,
      #    vm-swappiness=1, fstrim enable, 
      <nixos-hardware/lenovo/thinkpad/t14s/amd/gen1>
      ./hardware-configuration.nix
    ];

  networking = {
    hostName = "nerys"; # Define your hostname.
    hostId = "5c760be4"; # Required for ZFS
    networkmanager.enable = true;

    useDHCP = false; # Deprecated in favor of below per-device options
    interfaces.enp2s0f0.useDHCP = true;
    interfaces.wlp3s0.useDHCP = true;

    firewall = {
      enable = true;
      # 24800: barrier software KVM
      allowedTCPPorts = [ 24800 ];
    };
  };

  time.timeZone = "America/Los_Angeles";

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    # Uncomment to fall back to specific version, otherwise go with channel's
    kernelPackages = with pkgs; linuxPackages_5_9;
    extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];

    # Fix intermittent WiFi hiccups
    extraModprobeConfig = ''
      options iwlwifi 11n_disable=8
    '';
  };

  hardware.bluetooth.enable = true;

  hardware.trackpoint = {
    enable = true;
    # Default: 97
    speed = 127;
    # Default: 128
    sensitivity = 180;
  };


  # Virtualization
  virtualisation.docker.enable = true;
  virtualisation.libvirtd.enable = true;


  #
  # Packagae management
  #
  nix.autoOptimiseStore = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 21d";
  };
  nixpkgs.config.allowUnfree = true;

  powerManagement.cpuFreqGovernor = "ondemand";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  fonts.fonts = with pkgs; [
    fantasque-sans-mono
    font-awesome
    jost # <3 https://indestructibletype.com <3
  ];


  #
  # Xorg
  #
  services.xserver = {
    enable = true;
    desktopManager = {
      xterm.enable = false;
      wallpaper.mode = "fill";
    };

    displayManager = {
      defaultSession = "none+i3";
      sessionCommands = ''
        ${pkgs.dunst}/bin/dunst &
      '';
    };

    xautolock = {
      enable = true;

      # Lock
      locker = "${config.security.wrapperDir}/physlock";
      time = 20;

      # Suspend
      killer = "/run/current-system/systemd/bin/systemctl suspend";
      killtime = 35;

      # Notify
      enableNotifier = true;
      notify = 30; # In seconds
      notifier = "${pkgs.dunst}/bin/dunstify \"xautolock\" \"Locking soon!\"";

      # Top-right corer inhibits lock
      extraOptions = [ "-corners 0-00" "-cornerdelay 4" "-detectsleep" ];
    };

    windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps;
      extraPackages = with pkgs; [
        adapta-gtk-theme
        arandr
        dunst
        feh
        gnome3.zenity
        i3lock #default i3 screen locker
        (i3pystatus.override {extraLibs= [python3Packages.pytz];})
        inotify-tools
        lxappearance
        networkmanagerapplet
        numix-icon-theme
        pavucontrol
        pcmanfm
        rofi
        scrot
        syncthing
        xorg.xmodmap
      ];
    };

    # Enable and configure touchpad support
    libinput = {
      enable = true;
      # Natural-scolling only on touchpad
      naturalScrolling = true;
      additionalOptions = ''MatchIsTouchpad "on"'';
    };

    # Configure keymap in X11 and turn capslock into control
    layout = "us";
    xkbOptions = "ctrl:nocaps";
  };
  # Sets the preferred terminal emulator for i3-sensible-terminal
  environment.sessionVariables.TERMINAL = [ "alacritty" ];


  #
  # Services
  #
  services = {
    physlock = {
      enable = true;
      allowAnyUser = true;
    };
    fwupd.enable = true;

    tlp = {
      enable = true;
      settings = {
        START_CHARGE_THRESH_BAT0=40;
        STOP_CHARGE_THRESH_BAT0=50;
        RUNTIME_PM_DRIVER_BLACKLIST="\"mei_me nouveau nvidia pcieport radeon\"";
        RADEON_DPM_STATE_ON_AC="performance";
        RADEON_DPM_STATE_ON_BAT="battery";
        CPU_SCALING_GOVERNOR_ON_AC="performance";
        CPU_SCALING_GOVERNOR_ON_BAT="ondemand";
      };
    };

    picom = {
      enable = true;
      fade = false;
      inactiveOpacity = 1.0;
      shadow = true;
      shadowOpacity = 0.82;
    };

    gvfs.enable = true;

    redshift = {
      enable = true;
      executable = "/bin/redshift-gtk";
      brightness = {
        # Note the string values below.
        day = "1";
        night = "1";
      };
      temperature = {
        day = 5500;
        night = 3700;
      };
    };
  };
  location.provider = "geoclue2";


  #
  # Applications
  #
  programs = {
    # Install zsh and completions
    zsh = {
      enable = true;
      # Since I set my own completion options, disabling the global compinit
      # speeds up shell startup because it is only ran one time.
      enableGlobalCompInit = false;
    };
    nm-applet.enable = true;
    light.enable = true;
    ssh = {
      startAgent = true;
      askPassword = pkgs.lib.mkForce "${pkgs.plasma5.ksshaskpass.out}/bin/ksshaskpass";
    };
    gnupg.agent = {
      enable = true;
      #enableSSHSupport = true;
    };
  };
  # System-wide packages
  environment.systemPackages = with pkgs; [
    alacritty
    barrier
    bash
    blueberry
    bottom
    ccache
    chromium
    clinfo
    dmrconfig
    docker-compose
    firefox
    freecad
    fzf
    gcc
    gimp
    gnome3.file-roller
    gnumake
    inkscape
    joplin-desktop
    jq
    kdeApplications.kdeconnect-kde
    keepassxc
    lm_sensors
    meld
    ncdu
    neofetch
    nodePackages.npm
    nodejs
    obs-studio
    patchelf
    phoronix-test-suite
    pkg-config
    powertop
    python3
    python3Packages.pynvim
    qemu_kvm
    rsync
    rustup
    scrot
    shellcheck
    signal-desktop
    slack
    snes9x-gtk
    spotify
    steam
    tdesktop #telegram
    teensy-loader-cli
    tig
    usbutils
    vlc
    vulkan-tools
    xcape
    xclip
    xdotool
    youtube-dl
    zathura
    zoom-us
  ];


  system.stateVersion = "20.09";
}

