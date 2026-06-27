{ config
, pkgs
, modulesPath
, ... }:

{
  imports = [
    "${modulesPath}/installer/scan/not-detected.nix"

    modules/boot.nix
  ];

  environment.systemPackages = with pkgs; [
    # Binary Tools
    bintools
    # Better TOP
    btop
    # Connection tracking tools
    conntrack-tools
    # cURL
    curl
    # Display Mode Info Decode
    dmidecode
    # Ethernet Tool
    ethtool
    # Quick Stats Tool
    fastfetch
    # Version Tracking
    git
    # Intel GPU Tooling
    intel-gpu-tools
    # Internet Utilities
    inetutils
    # Internet Performance Monitoring
    iperf
    # llama.cpp Vulkan
    llama-cpp-vulkan
    vulkan-tools
    # Useful for finding who is accessing something
    lsof
    # NCurses Disk Usage
    ncdu
    # IPv6 Neighbor Discovery
    ndisc6
    # Network Tools
    net-tools
    # Hardware sensors
    lm_sensors
    # Open SSL
    openssl
    # PCI Utilies
    pciutils
    # Power Joular - Monitor Power Usage
    powerjoular
    # Power Top - Tuning Power Usage
    powertop
    # Powershell Misc
    psmisc
    # Screen
    screen
    # Verus Miner
    srbminer-multi
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
    # Yucky Intel CPU.
    intel.enable = true;
    # We have graphics support, might as well enable it; although, we don't need 32-bit support
    graphics.enable = true;
  };

  networking = {
    firewall.allowedTCPPorts = [
      8080
    ];
    hostId = "bade5fb2";
    hostName = "testing-box-localnet";
    interfaces = {
      eth0.useDHCP = true;
    };
    useDHCP = false;
    usePredictableInterfaceNames = false;
  };

  programs.zsh.enable = true;

  swapDevices = [{
    device = "/dev/disk/by-label/NIXOS_SWAP";
  }];

  users.users.vali.extraGroups = [ "video" "render" ];

  # modules/zfs/module.nix
  # modules/zfs/fragmentation.nix
  zfs.autoSnapshot.enable = true;
}