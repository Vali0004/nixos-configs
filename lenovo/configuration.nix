{ config, lib, modulesPath, pkgs, ... }:

let
  secrets = import ./network-secrets.nix { inherit lib; };

  agenix = builtins.getFlake "github:ryantm/agenix";
  agenixPkgs = agenix.outputs.packages.x86_64-linux;
in {
  imports = [
    agenix.nixosModules.default
    "${modulesPath}/installer/scan/not-detected.nix"
    boot/boot.nix
    home-manager/home.nix
    programs/spicetify.nix
    programs/ssh.nix
    programs/steam.nix
    programs/zsh.nix
    services/windowManager/dwm.nix
    services/bluetooth.nix
    services/displayManager.nix
    services/easyEffects.nix
    services/openssh.nix
    services/picom.nix
    services/pipewire.nix
    services/prometheus.nix
    #services/zdb.nix
  ];

  console.useXkbConfig = true;

  environment = {
    shellAliases = {
      l = null;
      ll = null;
      lss = "ls --color -lha";
      nuke = "shutdown -h now";
    };

    systemPackages = with pkgs; [
      # Key system (remote deploy)
      agenixPkgs.agenix
      # Terminal
      alacritty-graphics
      alsa-utils
      # Better TOP
      btop
      # Remote deploy
      colmena
      # Clipboard Manager
      clipmenu
      # cURL
      curl
      # XDG Mime/Desktop utils
      desktop-file-utils
      # Discord
      ((discord.override { withVencord = true; }).overrideAttrs {
        src = fetchurl {
          url = "https://stable.dl2.discordapp.net/apps/linux/0.0.106/discord-0.0.106.tar.gz";
          hash = "sha256-FqY2O7EaEjV0O8//jIW1K4tTSPLApLxAbHmw4402ees=";
        };
      })
      # SMBIOS
      dmidecode
      # Notification daemon
      dunst
      # Extended Display Id Data Decode
      edid-decode
      # Image/pdf viewer
      eog
      # Noise suppression
      easyeffects
      # Flexing
      fastfetch
      feh
      # Screenshot tool
      flameshot
      # Debugger
      gdb
      # Calculator
      gnome-calculator
      # sed
      gnused
      # GTK3, used for gtk-launch in dmenu
      gtk3
      # Browser
      google-chrome
      iperf
      # Media Player
      jellyfin-media-player
      # JSON parser
      jq
      # Archive tool
      kdePackages.ark
      # MS Paint
      kdePackages.kolourpaint
      # File browser
      nemo-with-extensions
      # cli unrar
      libarchive
      # Wormhole
      magic-wormhole
      # Video Player
      mpv
      # Directory info
      ncdu
      # Node.js
      nodejs_24
      # SSL Library
      openssl
      # Different audio control
      pamixer
      # Audio control
      pavucontrol
      # PCI Utils
      pciutils
      # Compositer
      picom
      # Audio player control
      playerctl
      # Audio server
      pulseaudio
      # GPU Control
      radeon-profile
      # App launcher
      rofi
      # Spotify mods
      spicetify-cli
      # Steam CMD
      steamcmd
      # System stats
      sysstat
      # tmux, screen replacement
      tmux
      # Tree, helps create file structures in text form
      tree
      # Unzip
      unzip
      # USB Utils
      usbutils
      # Editor
      vscode
      vscode-extensions.mkhl.direnv
      vscode-extensions.bbenoist.nix
      vscode-extensions.jnoortheen.nix-ide
      vscode-extensions.mshr-h.veriloghdl
      vscode-extensions.ms-vscode.cpptools-extension-pack
      vscode-extensions.ms-vscode.cmake-tools
      vscode-extensions.shardulm94.trailing-spaces
      # Vulkan
      vulkan-extension-layer
      vulkan-tools
      vulkan-validation-layers
      # wget
      wget
      # Packet sniffer
      wireshark
      # Wine
      wineWowPackages.stable
      winetricks
      # Electron hell
      xdg-launch
      xdg-utils
      # X11 helper
      xdotool
      # Fallback XDG file manager
      zenity
      zip
    ];

    variables = {
      CM_LAUNCHER = "rofi";
      G_MESSAGES_DEBUG = "all";
    };
  };

  fileSystems = {
    # Mount the Root Partition
    "/" = {
      device = "zpool/root";
      fsType = "zfs";
    };
    "/home" = {
      device = "zpool/home";
      fsType = "zfs";
    };
    "/nix" = {
      device = "zpool/nix";
      fsType = "zfs";
    };
    # Mount the EFI Partition
    "/boot" = {
      fsType = "vfat";
      label = "NIXOS_BOOT";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };
    # Mount the NFS
    "/mnt/data" = {
      device = "10.0.0.244:/data";
      fsType = "nfs";
      options = [ "x-systemd.automount" "noauto" "soft" ];
    };
  };

  fonts.packages = [ pkgs.nerd-fonts.dejavu-sans-mono ];

  hardware = {
    amdgpu.overdrive.enable = true;
    cpu.amd.updateMicrocode = config.hardware.enableRedistributableFirmware;
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [ "en_US.UTF-8/UTF-8" ];
  };

  networking = {
    extraHosts = ''
      10.0.0.31 lenovo
      10.0.0.124 chromeshit
      10.0.0.201 nixos-amd
      10.0.0.244 shitzen-nixos
      74.208.44.130 router-vps
    '';
    hostId = "2632ac4c";
    hostName = "lenovo";
    networkmanager.enable = false;
    useDHCP = false;
    useNetworkd = true;
    usePredictableInterfaceNames = false;
    wireless = {
      enable = true;
      networks = {
        "${secrets.wifi.ssid}" = {
          psk = secrets.wifi.password;
          extraConfig = ''
            freq_list=5180 5200 5220 5240
            bssid=6e:7f:f0:19:82:70
          '';
        };
      };
    };
  };

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    substituters = [
      "https://hydra.fuckk.lol"
      "https://cache.nixos.org/"
    ];
    trusted-users = [
      "root"
      "vali"
      "@wheel"
    ];
    trusted-public-keys = [
      "hydra.fuckk.lol:6+mPv9GwAFx/9J+mIL0I41pU8k4HX0KiGi1LUHJf7LY="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };

  nixpkgs.config = {
    allowUnfree = true;
  };

  nixpkgs.hostPlatform = "x86_64-linux";

  programs = {
    corectrl.enable = true;
    command-not-found.enable = true;
    dconf.enable = true;
    git = {
      enable = true;
      lfs.enable = true;
    };
  };

  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };

  security = {
    rtkit.enable = true;
    sudo.enable = true;
  };

  services = {
    # Linux GPU Configuration And Monitoring Tool
    lact.enable = true;
    udev.extraRules = ''
      # Keyboard
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="2e3c|8089", ATTRS{idProduct}=="c365|0009", GROUP="wheel"
      # RedOctane
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="1430", GROUP="wheel"
    '';
    xserver = {
      enable = true;
      # Disable XTerm
      excludePackages = [ pkgs.xterm ];
      desktopManager.xterm.enable = false;
      # Set our X11 Keyboard layout
      xkb.layout = "us";
    };
  };

  systemd.network = {
    enable = true;
    networks."30-wlan0" = {
      matchConfig.Name = "wlan0";
      linkConfig.RequiredForOnline = "carrier";
      networkConfig = {
        Address = [ "10.0.0.31/24" ];
        Gateway = "10.0.0.1";
        DNS = [
          "75.75.75.75"
          "75.75.76.76"
        ];
        IPv6AcceptRA = true;
      };
    };
  };

  system = {
    copySystemConfiguration = true;
    stateVersion = "25.11";
  };

  systemd.settings.Manager.RebootWatchdogSec = "0";

  systemd.user.services."xdg-desktop-portal".after = [ "graphical-session.target" ];
  systemd.user.services."xdg-desktop-portal-gtk".after = [ "graphical-session.target" ];

  time.timeZone = "America/Detroit";

  users = let
    my_keys = import ./../ssh_keys_personal.nix;
  in {
    defaultUserShell = pkgs.zsh;
    users.root.openssh.authorizedKeys.keys = my_keys;
    users.vali = {
      isNormalUser = true;
      extraGroups = [
        "corectrl"
        "input"
        "render"
        "tty"
        "wheel"
        "video"
      ];
      openssh.authorizedKeys.keys = my_keys;
      shell = pkgs.zsh;
      useDefaultShell = false;
    };
  };

  xdg.mime = {
    addedAssociations = {
      "x-scheme-handler/ftp" = "com.google.Chrome.desktop";
      "x-scheme-handler/http" = "com.google.Chrome.desktop";
      "x-scheme-handler/https" = "com.google.Chrome.desktop";
    };
    defaultApplications = {
      "application/xhtml+xml" = "com.google.Chrome.desktop";
      "text/plain" = "code.desktop";
      "text/html" = "com.google.Chrome.desktop";
      "text/xml" = "com.google.Chrome.desktop";
      "inode/directory" = "nemo.desktop";
    };
  };

  xdg.icons.enable = true;

  xdg.portal = {
    config.common.default = [ "gtk" ];
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal xdg-desktop-portal-gtk ];
    xdgOpenUsePortal = false;
  };
}
