{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix

      # Include repo modules
      ../../modules/minimum.nix
      ../../modules/audio.nix
      ../../modules/cpu-amd.nix
      ../../modules/gpu-amd.nix
      ../../modules/users.nix
      ../../modules/zfs.nix

      # Use NixOS/nixos-hardware for laptop specific settings
      #    Kernel > 5.8, acpi_backlight=native kernel param, acpi_call module,
      #    trackpoint enable & trackpoint emulate_wheel, tlp enable,
      #    vm-swappiness=1, fstrim enable, etc.
      <nixos-hardware/lenovo/thinkpad/t14s/amd/gen1>
    ];

  networking = {
    hostName = "nerys"; # Define your hostname.
    hostId = "5c760be4"; # Required for ZFS
    networkmanager.enable = true;
    networkmanager.wifi.powersave = true;

    useDHCP = false; # Deprecated in favor of below per-device options
    interfaces.wlp2s0.useDHCP = true;

    firewall = {
      enable = true;
      # Do not allow ports outside of home network at this moment.
      allowedTCPPorts = [];
      # LAN ports, specified via raw iptables commands to specify CIDR
      # 3000: node development server
      # 18266: port I use for flashing esp8266 devices OTA
      # 24800: barrier software KVM
      extraCommands = ''
        iptables -A INPUT -p tcp --dport 3000 -s 192.168.1.0/24 -j ACCEPT
        iptables -A INPUT -p tcp --dport 18266 -s 192.168.1.0/24 -j ACCEPT
        iptables -A INPUT -p tcp --dport 24800 -s 192.168.1.0/24 -j ACCEPT
      '';
    };
  };

  time.timeZone = "America/Los_Angeles";

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    # Uncomment to fall back to specific version, otherwise go with channel's
    kernelPackages = with pkgs; linuxPackages_latest;
    extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];
  };

  hardware.bluetooth = {
    enable = true;
    package = pkgs.bluezFull;
  };

  hardware.trackpoint = {
    enable = true;
    # Default: 97
    speed = 127;
    # Default: 128
    sensitivity = 215;
    emulateWheel = true;
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
    options = "--delete-older-than 14d";
  };
  nixpkgs.config.allowUnfree = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  fonts.fonts = with pkgs; [
    fantasque-sans-mono
    font-awesome
    noto-fonts-emoji
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
      lightdm = {
        enable = true;
        background = "/etc/nixos/background-image";
      };
      defaultSession = "none+i3";
      sessionCommands = ''
        ${pkgs.dunst}/bin/dunst &
      '';
    };

    xautolock = {
      enable = true;

      # Lock
      locker = "${config.security.wrapperDir}/physlock";
      time = 25;

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
        i3status-rust
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
      touchpad.naturalScrolling = true;
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

    autorandr.enable = true;

    fwupd.enable = true;

    tlp = {
      enable = true;
      settings = {
        #USB_BLACKLIST_BTUSB=1;
        START_CHARGE_THRESH_BAT0=45;
        STOP_CHARGE_THRESH_BAT0=55;
        RUNTIME_PM_DRIVER_BLACKLIST="\"mei_me nouveau nvidia pcieport radeon\"";
        RADEON_DPM_STATE_ON_AC="performance";
        RADEON_DPM_STATE_ON_BAT="battery";
        CPU_SCALING_GOVERNOR_ON_AC="ondemand";
        CPU_SCALING_GOVERNOR_ON_BAT="ondemand";
        CPU_BOOST_ON_AC=1;
        CPU_BOOST_ON_BAT=0;
      };
    };

    picom = {
      enable = true;
      vSync = true;
      fade = false;
      inactiveOpacity = 1.0;
      shadow = true;
      shadowOpacity = 0.82;
      backend = "glx";
      opacityRules = [
        "96:class_g = 'Rofi'"
        "0:_NET_WM_STATE@[0]:32a *= '_NET_WM_STATE_HIDDEN'"
        "0:_NET_WM_STATE@[1]:32a *= '_NET_WM_STATE_HIDDEN'"
        "0:_NET_WM_STATE@[2]:32a *= '_NET_WM_STATE_HIDDEN'"
        "0:_NET_WM_STATE@[3]:32a *= '_NET_WM_STATE_HIDDEN'"
        "0:_NET_WM_STATE@[4]:32a *= '_NET_WM_STATE_HIDDEN'"
      ];
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
        day = 4800;
        night = 3300;
      };
    };
  };

  location = {
    provider = "manual";
    latitude = 45.0;
    longitude = -122.5;
  };

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
    direnv
    dmrconfig
    docker-compose
    firefox
    freecad
    fritzing
    fzf
    gcc
    gimp
    gnome3.file-roller
    gnome3.gnome-calculator
    gnumake
    inkscape-with-extensions
    jq
    keepassxc
    lm_sensors
    meld
    ncdu
    neofetch
    nodePackages.npm
    nodejs
    obs-studio
    patchelf
    pick-colour-picker
    pkg-config
    platformio
    powertop
    python3Full
    python3Packages.pynvim
    qemu_kvm
    rsync
    scrot
    shellcheck
    signal-desktop
    slack
    snes9x-gtk
    spotify
    tdesktop #telegram
    teensy-loader-cli
    tig
    tor-browser-bundle-bin
    usbutils
    unzip
    vlc
    vulkan-tools
    xcape
    xclip
    xdotool
    youtube-dl
    zathura
  ];

  system.stateVersion = "21.03";
}

