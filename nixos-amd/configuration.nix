{ config, lib, modulesPath, pkgs, ... }:

let
  secrets = import ./network-secrets.nix { inherit lib; };
in {
  # TODO: Use nixpkgs overlay, instead of the mess that is agenix & nixGaming
  # due to a non-flake based config
  imports = [
    "${modulesPath}/installer/scan/not-detected.nix"
    boot/boot.nix
    home-manager/home.nix
    pkgs/module.nix
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
    ./xdg.nix
  ];

  console.useXkbConfig = true;

  environment = {
    shellAliases = {
      l = null;
      ll = null;
      lss = "ls --color -lha";
    };
    variables = {
      AGE_IDENTITIES = "/home/vali/.ssh/nixos_main";
      CM_LAUNCHER = "rofi";
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

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.supportedLocales = [ "en_US.UTF-8/UTF-8" ];

  networking = {
    defaultGateway = {
      address = "10.0.0.1";
      interface = "bond0";
    };
    defaultGateway6 = {
      address = "fe80::1";
      interface = "bond0";
    };
    bonds = {
      bond0 = {
        driverOptions = {
          miimon = "100";
          mode = "active-backup";
          primary_reselect = "better";
        };
        interfaces = [
          "eth0"
          "wlan0"
        ];
      };
    };
    extraHosts = ''
      10.0.0.31 lenovo
      10.0.0.124 chromeshit
      10.0.0.201 nixos-amd
      10.0.0.244 shitzen-nixos
      74.208.44.130 router-vps
    '';
    hostName = "nixos-amd";
    interfaces = {
      bond0 = {
        ipv4.addresses = [{
          address = "10.0.0.201";
          prefixLength = 24;
        }];
        ipv6.addresses = [
          {
            address = "2601:406:8101:b1ae:1017:2bff:fed6:5519";
            prefixLength = 64;
          }
          {
            address = "fe80::1017:2bff:fed6:5519";
            prefixLength = 64;
          }
        ];
      };
    };
    nameservers = [
      "2601:406:8101:b1ae:9e6b:ff:fea4:1340"
      "2001:558:feed::1"
      "10.0.0.244"
      "75.75.75.75"
    ];
    useDHCP = false;
    wireless = {
      enable = true;
      networks = {
        "${secrets.wifi.ssid}" = {
          psk = secrets.wifi.password;
        };
      };
      userControlled.enable = true;
    };
    usePredictableInterfaceNames = false;
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

  nixpkgs = {
    config.allowUnfree = true;
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

  systemd.settings.Manager.RebootWatchdogSec = "0";

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
}
