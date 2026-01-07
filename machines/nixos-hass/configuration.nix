{ config
, pkgs
, modulesPath
, ... }:

{
  imports = [
    "${modulesPath}/installer/scan/not-detected.nix"

    modules/boot.nix

    programs/agenix.nix

    services/mqtt/mosquitto.nix
    services/mqtt/zigbee2mqtt.nix

    services/home-assistant.nix

    services/postgresql.nix
    services/prometheus.nix

    services/udev.nix
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
    # Internet Utilities
    inetutils
    # Internet Performance Monitoring
    iperf
    # Useful for finding who is accessing something
    lsof
    # Mini Certificate Authority
    minica
    # NCurses Disk Usage
    ncdu
    # IPv6 Neighbor Discovery
    ndisc6
    # Network Tools
    net-tools
    # MBIM Tools
    libmbim
    # Hardware sensors
    lm_sensors
    # Open SSL
    openssl
    # PCI Utilies
    pciutils
    # Pico COM (sometimes easier than minicom)
    picocom
    # Power Joular - Monitor Power Usage
    powerjoular
    # Power Top - Tuning Power Usage
    powertop
    # Powershell Misc
    psmisc
    # Screen
    screen
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
    # Enable Wi-Fi (Yuck, I know)
    wifi.enable = true;
  };

  networking = {
    bonds.bond0 = {
      interfaces = [ "eth0" "wlan0" ];
      driverOptions = {
        miimon = "100";
        mode = "active-backup";
        primary = "eth0";
        primary_reselect = "always";
      };
    };
    hostId = "bade5fb2";
    hostName = "nixos-hass";
    interfaces = {
      bond0.useDHCP = true;
    };
    useDHCP = false;
    usePredictableInterfaceNames = false;
  };

  # Setup auto-tune by default
  powerManagement.powertop.enable = true;

  programs.zsh.enable = true;

  swapDevices = [{
    device = "/dev/disk/by-label/NIXOS_SWAP";
  }];

  users.users.vali.extraGroups = [ "video" "render" ];

  # modules/zfs/module.nix
  # modules/zfs/fragmentation.nix
  zfs.autoSnapshot.enable = true;
}