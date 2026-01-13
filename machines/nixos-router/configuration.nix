{ config
, pkgs
, modulesPath
, ... }:

{
  imports = [
    "${modulesPath}/installer/scan/not-detected.nix"
    modules/boot.nix

    networking/router/default.nix
    networking/dhcp.nix
    networking/nat.nix
    networking/sysctl.nix

    services/prometheus.nix
    services/routerd.nix
  ];

  router = {
    wanInterface = "enp1s0f0";
    lanInterfaces = [
      "enp2s0"
      "enp1s0f1"
    ];
  };

  environment.systemPackages = with pkgs; [
    # Binary Tools
    bintools
    # Binary Walk
    binwalk
    # Better TOP
    btop
    # Connection tracking tools
    conntrack-tools
    # cURL
    curl
    # CPU Power Management
    linuxKernel.packages.linux_6_12.cpupower
    # Display Mode Info Decode
    dmidecode
    # Ethernet Tool
    ethtool
    # Modern Neofetch
    fastfetch
    # Version Tracking
    git
    # Internet Utilities
    inetutils
    # Internet performance monitoring
    iperf
    # Mini Certificate Authority
    minica
    # NCurses Disk usage
    ncdu
    # IPv6 Neighbor Discovery
    ndisc6
    # Network Tools
    net-tools
    # Open SSL
    openssl
    # PCI Utilies
    pciutils
    # Screen
    screen
    # TCP Dump
    tcpdump
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
    hostName = "nixos-router";
    # Disable global DHCP, as we do it per-interface instead
    useDHCP = false;
    # We actually have multiple PHYs, so this is needed.
    usePredictableInterfaceNames = true;
  };

  # Setup auto-tune by default
  powerManagement.powertop.enable = true;

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