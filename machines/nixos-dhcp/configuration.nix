{ config
, pkgs
, modulesPath
, ... }:

{
  imports = [
    "${modulesPath}/installer/scan/not-detected.nix"
    modules/boot.nix

    networking/dhcp.nix
    networking/sysctl.nix

    #services/pihole.nix
    services/prometheus.nix
  ];

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
    # Display Mode Info Decode
    dmidecode
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
    # Yucky Intel CPU.
    cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;
    enableRedistributableFirmware = true;
    # We have graphics support, might as well enable it; although, we don't need 32-bit support
    graphics.enable = true;
  };

  networking = {
    hostId = "bade5fb2";
    hostName = "nixos-dhcp";
    # Disable global DHCP, as we do it per-interface instead
    useDHCP = false;
    # We actually have multiple PHYs, so this is needed.
    usePredictableInterfaceNames = true;
  };

  swapDevices = [{
    device = "/dev/disk/by-label/NIXOS_SWAP";
  }];

  users.users = {
    vali.extraGroups = [ "video" "render" ];
  };

  # modules/zfs/module.nix
  # modules/zfs/fragmentation.nix
  zfs = {
    autoSnapshot.enable = true;
    fragmentation = {
      enable = true;
      openFirewall = true;
    };
  };
}