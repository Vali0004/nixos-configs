{ config, lib, modulesPath, pkgs, ... }:

{
  imports = [
    "${modulesPath}/installer/scan/not-detected.nix"
    boot/boot.nix
    home-manager/home.nix
    programs/ssh.nix
    services/windowManager/dwm.nix
    services/displayManager.nix
    services/monado.nix
    services/picom.nix
    services/syslog.nix
    ./pkgs.nix
  ];

  environment.variables = {
    AGE_IDENTITIES = "/home/vali/.ssh/nixos_main";
    CM_LAUNCHER = "dmenu";
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

  gtk.enable = true;

  hardware = {
    amdgpu = {
      enable = true;
      allowOverclocking = true;
    };
    bluetooth.enable = true;
    opentabletdriver = {
      enable = true;
      daemon.enable = true;
    };
    virtualisation.enable = true;
  };

  networking = {
    bonds.bond0 = {
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
    defaultGateway = {
      address = "10.0.0.1";
      interface = "bond0";
    };
    defaultGateway6 = {
      address = "fe80::1";
      interface = "bond0";
    };
    firewall.allowedUDPPorts = [ 5055 ];
    hostName = "nixos-amd";
    interfaces.bond0 = {
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
    nameservers = [
      "2601:406:8101:b1ae:9e6b:ff:fea4:1340"
      "2001:558:feed::1"
      "10.0.0.244"
      "75.75.75.75"
    ];
    useDHCP = false;
    usePredictableInterfaceNames = false;
  };

  programs = {
    corectrl.enable = true;
    command-not-found.enable = true;
    dconf.enable = true;
    element-desktop.enable = true;
    git = {
      enable = true;
      lfs.enable = true;
    };
    google-chrome.enable = true;
    java.enable = true;
    kde-ark.enable = true;
    nemo.enable = true;
    steam.enable = true;
    unityhub.enable = true;
    vscode.enable = true;
    wireshark = {
      dumpcap.enable = true;
      enable = true;
      usbmon.enable = true;
    };
  };

  security = {
    rtkit.enable = true;
    sudo.enable = true;
  };

  services = {
    flatpak.enable = true;
    # Linux GPU Configuration And Monitoring Tool
    lact.enable = true;
    udev.extraRules = ''
      # Keyboard
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="2e3c|8089", ATTRS{idProduct}=="c365|0009", GROUP="wheel"
      # HTC
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="0bb4", GROUP="wheel"
      # SlimeVR
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="1209", GROUP="wheel"
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

  system.stateVersion = "25.11";

  systemd.settings.Manager.RebootWatchdogSec = "0";

  users.users.vali = {
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
      "wireshark"
      "usbmon"
    ];
    useDefaultShell = false;
    shell = pkgs.zsh;
  };

  xdg.enable = true;
}
