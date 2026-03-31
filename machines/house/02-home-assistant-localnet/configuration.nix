{ config
, pkgs
, modulesPath
, ... }:

{
  imports = [
    "${modulesPath}/installer/scan/not-detected.nix"
    modules/boot.nix

    services/mqtt/mosquitto.nix
    services/mqtt/zigbee2mqtt.nix

    services/home-assistant.nix
    services/postgresql.nix
    services/prometheus.nix
    services/udev.nix
  ];

  environment.systemPackages = with pkgs; [
    # Better TOP
    btop
    # cURL
    curl
    # Ethernet tool
    ethtool
    # Version Tracking
    git
    # Modern neofetch
    fastfetch
    # NCurses Disk usage
    ncdu
    # IPv6 Neighbor Discovery
    ndisc6
    # PCI Utilies
    pciutils
    # TCP Dump
    tcpdump
    # USB Utilies
    usbutils
    # Web Get
    wget
  ];

  fileSystems = {
    "/" = {
      device = "zpool/root";
      fsType = "zfs";
    };
    "/home" = {
      device = "zpool/home";
      neededForBoot = true;
      fsType = "zfs";
    };
    "/nix" = {
      device = "zpool/nix";
      neededForBoot = true;
      fsType = "zfs";
    };
    "/boot" = {
      label = "NIXOS_BOOT";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };
  };

  hardware = {
    intel.enable = true;
    # We have graphics support, might as well enable it; although, we don't need 32-bit support
    graphics.enable = true;
  };

  networking = {
    hostId = "bade5fb2";
    hostName = "home-assistant-localnet";
    interfaces = {
      eth0.useDHCP = true;
    };
    usePredictableInterfaceNames = false;
  };

  swapDevices = [{
    device = "/dev/disk/by-label/NIXOS_SWAP";
  }];

  users.users = {
    vali.extraGroups = [ "video" "render" ];
  };

  # modules/zfs/module.nix
  # modules/zfs/fragmentation.nix
  zfs.autoSnapshot.enable = true;
}