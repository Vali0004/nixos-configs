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
  osu-base = pkgs.callPackage ./pkgs/osu {
    osu-mime = nixGamingPkgs.osu-mime;
    wine-discord-ipc-bridge = nixGamingPkgs.wine-discord-ipc-bridge;
    proton-osu-bin = nixGamingPkgs.proton-osu-bin;
  };
  osu-stable = osu-base;
  osu-gatari = (osu-base.override {
    desktopName = "osu!gatari";
    pname = "osu-gatari";
    launchArgs = "-devserver gatari.pw";
  });
in {
  imports = [
    agenix.nixosModules.default
    nixGaming.nixosModules.pipewireLowLatency
    "${modulesPath}/installer/scan/not-detected.nix"
    boot/boot.nix
    home-manager/home.nix
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
      dienow = "shutdown -h now";
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
      # Better TOP
      btop
      # BeamMP
      (callPackage ./pkgs/beammp-launcher {})
      # Cache system
      cachix
      # Remote deploy
      colmena
      # Cider - Alternative Apple Music Client
      cider-2
      # Clipboard Manager
      clipmenu
      clipmenu-paste
      # cURL
      curl
      # macOS Translation Layer
      (callPackage ./pkgs/darling {})
      # XDG Mime/Desktop utils
      desktop-file-utils
      # Binary utility, desined to identify what a binary is (including the compiler)
      detect-it-easy
      # Directory envorinment
      direnv
      # dos2unix tool
      dos2unix
      # Discord
      ((discord.override { withVencord = true; }).overrideAttrs {
        src = fetchurl {
          url = "https://stable.dl2.discordapp.net/apps/linux/0.0.106/discord-0.0.106.tar.gz";
          hash = "sha256-FqY2O7EaEjV0O8//jIW1K4tTSPLApLxAbHmw4402ees=";
        };
      })
      # SMBIOS
      dmidecode
      # App launcher
      dmenu
      # .NET Disassembler
      (callPackage ./pkgs/dnspy {})
      # Notification daemon
      dunst
      # Extended Display Id Data Decode
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
      # Hex-Rays IDA Pro 9.0 Beta
      (callPackage ./pkgs/ida-pro {})
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
      # Killall (psmisc)
      killall
      # File browser
      nemo-with-extensions
      # Fixes BeamNG
      nss
      # cli unrar
      libarchive
      # X CVT
      libxcvt
      # Wormhole
      magic-wormhole
      # COM Reader
      minicom
      # 360-deploy
      morph
      # Video Player
      mpv
      # Directory info
      ncdu
      # nRF Studio
      (callPackage ./pkgs/nordic {})
      # SEGGER JLink
      (callPackage ./pkgs/nordic/jlink {})
      # Adafurit nRF Util
      (callPackage ./pkgs/nordic/nrfutil {})
      # Node.js
      nodejs_24
      obs-studio
      openssl
      # Hex Editor
      okteta
      # nix-gaming pkg, slightly modified
      osu-gatari
      osu-stable
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
      # Thunderstore (Mod Manager)
      r2modman
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
      # System stats
      sysstat
      # TeamSpeak
      teamspeak3
      # tmux, screen replacement
      tmux
      # Remote shell service over tmux
      tmate
      # Tree, helps create file structures in text form
      tree
      # Unity
      (unityhub.overrideAttrs (old: {
        postInstall = (old.postInstall or "") + ''
          ${desktop-file-utils}/bin/update-desktop-database $out/share/applications
        '';
      }))
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
      G_MESSAGES_DEBUG = "all";
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
    # Mount D:\
    "/mnt/d" = {
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
    extraHosts = ''
      10.0.0.31 lenovo
      10.0.0.124 chromeshit
      10.0.0.201 nixos-amd
      10.0.0.244 shitzen-nixos
      74.208.44.130 router-vps
    '';
    hostName = "nixos-amd";
    useDHCP = false;
    useNetworkd = true;
    networkmanager.enable = false;
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
    cudaSupport = false;
    rocmSupport = false;
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
    # Linux GPU Configuration And Monitoring Tool
    lact.enable = true;
    udev.extraRules = ''
      # Keyboard
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="2e3c|8089", ATTRS{idProduct}=="c365|0009", GROUP="wheel"
      # HTC
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="0bb4", GROUP="wheel"
      # Oculus
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="2833", GROUP="wheel"
      SUBSYSTEMS=="hidraw", ATTRS{idVendor}=="2833", GROUP="wheel", MODE="0666"
      # Steam
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="28de", GROUP="wheel"
      # RedOctane
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="1430", GROUP="wheel"
      # Set /dev/bus/usb/*/* as read-write for the wheel group (0666) for Nordic Semiconductor devices
      SUBSYSTEM=="usb", ATTRS{idVendor}=="1915", MODE="0666"
      # Set /dev/bus/usb/*/* as read-write for the wheel group (0666) for WCH-CN devices
      SUBSYSTEM=="usb", ATTRS{idVendor}=="1a86", MODE="0666"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="1d6b", MODE="0666"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="1209", MODE="0666"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="0bda", MODE="0666"
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
          DNS = [
            "10.0.0.244"
            "75.75.75.75"
          ];
          IPv6AcceptRA = true;
        };
      };
    };
  };

  systemd.settings.Manager.RebootWatchdogSec = "0";

  systemd.user.services."xdg-desktop-portal".after = [ "graphical-session.target" ];
  systemd.user.services."xdg-desktop-portal-gtk".after = [ "graphical-session.target" ];

  time.timeZone = "America/Detroit";

  users = {
    defaultUserShell = pkgs.zsh;
    users.vali = {
      isNormalUser = true;
      extraGroups = [
        "corectrl"
        "input"
        "plugdev"
        "qemu-libvirtd"
        "render"
        "tty"
        "video"
        "wheel"
      ];
      useDefaultShell = false;
      shell = pkgs.zsh;
    };
  };

  xdg.mime = {
    addedAssociations = {
      "x-scheme-handler/element" = "element-desktop.desktop";
      "x-scheme-handler/io.element.desktop" = "element-desktop.desktop";
      "x-scheme-handler/ftp" = "com.google.Chrome.desktop";
      "x-scheme-handler/http" = "com.google.Chrome.desktop";
      "x-scheme-handler/https" = "com.google.Chrome.desktop";
      "x-scheme-handler/roblox" = "org.vinegarhq.Sober.desktop";
      "x-scheme-handler/roblox-player" = "org.vinegarhq.Sober.desktop";
      "x-scheme-handler/unityhub" = "unityhub.desktop";
    };
    defaultApplications = {
      "application/zip" = "org.kde.ark.desktop";
      "application/xhtml+xml" = "com.google.Chrome.desktop";
      "text/plain" = "code.desktop";
      "text/html" = "com.google.Chrome.desktop";
      "text/xml" = "com.google.Chrome.desktop";
      "inode/directory" = "nemo.desktop";
    };
  };

  xdg.icons.enable = true;

  xdg.portal = {
    config = {
      common.default = [ "gtk" ];
    };
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal xdg-desktop-portal-gtk ];
    xdgOpenUsePortal = false;
  };
}
