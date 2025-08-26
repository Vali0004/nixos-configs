{ config, lib, modulesPath, pkgs, ... }:

let
  secrets = import ./network-secrets.nix { inherit lib; };

  flameshot_fuckk_lol = pkgs.writeScriptBin "flameshot_fuckk_lol" ''
    ${pkgs.flameshot}/bin/flameshot gui --accept-on-select -r > /tmp/screenshot.png
    ${pkgs.curl}/bin/curl -H "authorization: ${secrets.zipline.authorization}" https://holy.fuckk.lol/api/upload -F file=@/tmp/screenshot.png -H 'content-type: multipart/form-data' | ${pkgs.jq}/bin/jq -r .files[0].url | tr -d '\n' | ${pkgs.xclip}/bin/xclip -selection clipboard
  '';

  fastfetch_simple = pkgs.writeScriptBin "fastfetch_simple" ''
    ${pkgs.fastfetch}/bin/fastfetch --config /home/vali/.config/fastfetch/simple.jsonc
  '';

  dmenu = ((pkgs.dmenu.override {
    conf = ./dmenu-config.h;
  }).overrideAttrs (old: {
    buildInputs = (old.buildInputs or []) ++ [ pkgs.libspng ];
    src = /home/vali/development/dmenu;
    postPatch = ''
      ${old.postPatch or ""}
      sed -ri -e 's!\<(dmenu|dmenu_path_desktop|stest)\>!'"$out/bin"'/&!g' dmenu_run_desktop
      sed -ri -e 's!\<stest\>!'"$out/bin"'/&!g' dmenu_path_desktop
    '';
  }));
  clipmenu-paste = pkgs.callPackage ./clipmenu-paste.nix { inherit dmenu; };

  agenix = builtins.getFlake "github:ryantm/agenix";
  agenixPkgs = agenix.outputs.packages.x86_64-linux;

  nixGaming = builtins.getFlake "github:fufexan/nix-gaming";
  nixGamingPkgs = nixGaming.outputs.packages.x86_64-linux;
in {
  imports = [
    agenix.nixosModules.default
    nixGaming.nixosModules.pipewireLowLatency
    "${modulesPath}/installer/scan/not-detected.nix"
    boot/boot.nix
    home-manager/home.nix
    pkgs/adafruit-nrfutil.nix
    pkgs/cider.nix
    pkgs/nordic.nix
    programs/spicetify.nix
    programs/ssh.nix
    programs/steam.nix
    programs/zsh.nix
    services/windowManager/dwm.nix
    #services/windowManager/i3.nix
    services/bluetooth.nix
    services/displayManager.nix
    services/easyEffects.nix
    services/monado.nix
    services/picom.nix
    services/pipewire.nix
    services/syslog.nix
    services/toxvpn.nix
    services/virtualisation.nix
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "libxml2-2.13.8"
  ];

  console.useXkbConfig = true;

  environment = {
    shellAliases = {
      l = null;
      ll = null;
      lss = "ls --color -lha";
    };

    systemPackages = with pkgs; [
      # Key system (remote deploy)
      agenixPkgs.agenix
      # Terminal
      alacritty-graphics
      alsa-utils
      # XDG debug
      bustle
      bridge-utils
      btop
      # BeamMP
      (callPackage ./pkgs/beammp-launcher.nix {})
      # Cache system
      cachix
      # Remote deploy
      colmena
      curl
      # Clipboard Manager
      clipmenu
      clipmenu-paste
      # macOS Translation Layer
      (callPackage ./pkgs/darling.nix {})
      dos2unix
      direnv
      ((discord.override { withVencord = true; }).overrideAttrs {
        src = fetchurl {
          url = "https://stable.dl2.discordapp.net/apps/linux/0.0.106/discord-0.0.106.tar.gz";
          hash = "sha256-FqY2O7EaEjV0O8//jIW1K4tTSPLApLxAbHmw4402ees=";
        };
      })
      dmidecode
      # App launcher
      dmenu
      # Notification daemon
      dunst
      edid-decode
      # Matrix client
      element-desktop
      envsubst
      # Image/pdf viewer
      eog
      # Noise suppression
      easyeffects
      evtest
      # Flexing
      fastfetch
      fastfetch_simple
      feh
      # Screenshot tool
      flameshot
      # Screenshot tool with my uploader secret
      flameshot_fuckk_lol
      # Tool used to check file types
      file
      fzf
      # Debugger
      gdb
      # Binary hacking
      ghidra
      # Calculator
      gnome-calculator
      # sed
      gnused
      # GTK3, used for gtk-launch in dmenu
      gtk3
      # Browser
      google-chrome
      # Ping tool, used to ping a specific port
      hping
      iperf
      # IRC Client
      irssi
      # Media Player
      jellyfin-media-player
      # JSON parser
      jq
      # Archive tool
      kdePackages.ark
      # MS Paint
      kdePackages.kolourpaint
      # CAD software
      kicad
      # File browser
      nemo-with-extensions
      # Fixes BeamNG
      nss
      # Linux GPU Configuration And Monitoring Tool
      lact
      # cli unrar
      libarchive
      # X CVT
      libxcvt
      # LLM
      llama-cpp
      # LLM Studio, frontend wrapper around llama-cpp
      lmstudio
      # Wormhole
      magic-wormhole
      # COM Reader
      minicom
      # 360-deploy
      morph
      # Video Player
      mpv
      nodejs_24
      # nix-gaming
      (nixGamingPkgs.osu-stable.override { useGameMode = false; })
      nixGamingPkgs.wine-discord-ipc-bridge
      obs-studio
      openssl
      # Tablet Driver
      opentabletdriver
      # Different audio control
      pamixer
      # Audio control
      pavucontrol
      pciutils
      # Compositer
      picom
      playerctl
      # Minecraft launcher
      prismlauncher
      protontricks
      # Audio server
      pulseaudio
      # VM
      qemu_kvm
      (writeShellScriptBin "qemu-system-x86_64-uefi" ''
        qemu-system-x86_64 \
          -bios ${OVMF.fd}/FV/OVMF.fd \
          "$@"
      '')
      # GPU Control
      radeon-profile
      # socat - listener
      socat
      # Spotify mods
      spicetify-cli
      # Steam CMD
      steamcmd
      # Syncplay, allows for syncing video streams with others via mpv
      syncplay
      sysstat
      tmux
      # Remote shell service
      tmate
      # Tree, helps create file structures in text form
      tree
      # Unity
      unityhub
      # Unzip
      unzip
      # USB Utils
      usbutils
      # Alternative Discord client
      vesktop
      # vi
      vim
      # VM helper
      virt-viewer
      # VRChat Friendship Management
      vrcx
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
      AGE_IDENTITIES = "/home/vali/.ssh/nixos_main";
      CM_LAUNCHER = "dmenu";
    };
  };

  fileSystems = {
    # Mount the Root Partition
    "/" = {
      fsType = "ext4";
      label = "NIXOS_ROOT";
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
    # Mount the Windows C:\ drive
    "/mnt/c" = {
      device = "/dev/disk/by-uuid/BE68F85A68F812BF";
      fsType = "ntfs";
    };
    # Mount X:\
    "/mnt/x" = {
      device = "/dev/disk/by-uuid/06BEE3E0BEE3C671";
      fsType = "ntfs";
      options = [ "x-systemd.automount" ];
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
    opentabletdriver = {
      enable = true;
      daemon.enable = true;
    };
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [ "en_US.UTF-8/UTF-8" ];
  };

  networking = {
    hostName = "nixos-amd";
    useDHCP = false;
    useNetworkd = true;
    networkmanager.enable = false;
    wireless = {
      enable = true;
      networks = {
        "${secrets.wifi.ssid}" = {
          psk = secrets.wifi.password;
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
      #"https://hydra.fuckk.lol"
      "https://cache.nixos.org/"
    ];
    trusted-users = [
      "root"
      "vali"
      "@wheel"
    ];
    trusted-public-keys = [
      #"hydra.fuckk.lol:6+mPv9GwAFx/9J+mIL0I41pU8k4HX0KiGi1LUHJf7LY="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };

  nixpkgs = {
    config.allowUnfree = true;
    config.cudaSupport = false;
    config.rocmSupport = true;
    hostPlatform = "x86_64-linux";
  };

  programs = {
    corectrl.enable = true;
    command-not-found.enable = true;
    dconf.enable = true;
    git = {
      enable = true;
      lfs.enable = true;
    };
    java.enable = true;
  };

  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };

  security = {
    pki.certificates = [
      (builtins.readFile ./cloudflare-ecc.pem)
      (builtins.readFile ./beammp.pem)
    ];
    rtkit.enable = true;
    sudo.enable = true;
  };

  services = {
    cloudflare-warp.enable = true;
    flatpak.enable = true;
    lact.enable = true;
    udev.extraRules = ''
      # Keyboard
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="2e3c|8089", ATTRS{idProduct}=="c365|0009", GROUP="wheel"
      # HTC
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="0bb4", GROUP="wheel"
      # Steam
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="28de", GROUP="wheel"
      # RedOctane
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="1430", GROUP="wheel"
      # Set /dev/bus/usb/*/* as read-write for the wheel group (0666) for Nordic Semiconductor devices
      SUBSYSTEM=="usb", ATTRS{idVendor}=="1915", MODE="0666"
      # Flag USB CDC ACM devices, handled below
      # Set USB CDC ACM devnodes as read-write for the wheel group
      KERNEL=="ttyACM[0-9]*", SUBSYSTEM=="tty", SUBSYSTEMS=="usb", ATTRS{idVendor}=="1915", MODE="0666", ENV{NRF_CDC_ACM}="1"
      ENV{NRF_CDC_ACM}=="1", ENV{ID_MM_CANDIDATE}="0", ENV{ID_MM_DEVICE_IGNORE}="1"
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

  # 8GiB Swap
  swapDevices = [{
    device = "/var/lib/swap1";
    size = 8192;
  }];

  system = {
    copySystemConfiguration = true;
    stateVersion = "25.11";
  };

  systemd.network = {
    enable = true;
    netdevs = {
      "10-bond0" = {
        netdevConfig = {
          Kind = "bond";
          Name = "bond0";
        };
        bondConfig = {
          Mode = "active-backup";
          MIIMonitorSec = "0.100";
          PrimaryReselectPolicy = "better";
        };
      };
    };
    networks = {
      "30-enp10s0" = {
        matchConfig.Name = "enp10s0";
        networkConfig.Bond = "bond0";
        networkConfig.PrimarySlave = true;
      };

      "30-wlp9s0" = {
        matchConfig.Name = "wlp9s0";
        networkConfig.Bond = "bond0";
      };

      "40-bond0" = {
        matchConfig.Name = "bond0";
        linkConfig.RequiredForOnline = "carrier";
        networkConfig = {
          Address = [ "10.0.0.201/24" ];
          Gateway = "10.0.0.1";
          DNS = [ "75.75.75.75" "75.75.76.76" ];
          IPv6AcceptRA = true;
        };
      };
    };
  };

  systemd.settings.Manager.RebootWatchdogSec = "0";

  time.timeZone = "America/Detroit";

  users = {
    defaultUserShell = pkgs.zsh;
    users.vali = {
      isNormalUser = true;
      extraGroups = [
        "corectrl"
        "qemu-libvirtd"
        "render"
        "tty"
        "wheel"
        "video"
      ];
      useDefaultShell = false;
      shell = pkgs.zsh;
    };
  };

  xdg.mime = let
    applications = {
      "application/zip" = "org.kde.ark.desktop";
      "text/plain" = "code.desktop";
      "inode/directory" = "nemo.desktop";
      "x-scheme-handler/element" = "element-desktop.desktop";
      "x-scheme-handler/io.element.desktop" = "element-desktop.desktop";
      "x-scheme-handler/roblox" = "org.vinegarhq.Sober.desktop";
      "x-scheme-handler/roblox-player" = "org.vinegarhq.Sober.desktop";
      "application/xhtml+xml" = "com.google.Chrome.desktop";
      "text/html" = "com.google.Chrome.desktop";
      "text/xml" = "com.google.Chrome.desktop";
      "x-scheme-handler/ftp" = "com.google.Chrome.desktop";
      "x-scheme-handler/http" = "com.google.Chrome.desktop";
      "x-scheme-handler/https" = "com.google.Chrome.desktop";
    };
  in {
    addedAssociations = applications;
    defaultApplications = applications;
  };

  xdg.portal = {
    config.common.default = [ "gtk" ];
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal xdg-desktop-portal-gtk ];
    xdgOpenUsePortal = true;
  };
}
