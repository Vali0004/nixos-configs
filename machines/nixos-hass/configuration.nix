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
      };
    };
    dhcpcd = {
      # TP-Link is stupid...
      #
      # eth0: adding route to fdb5:8d30:9e81:1::/64 via fe80::1691:38ff:fed0:2729
      # eth0: dhcp_envoption 24.0/3: malformed embedded option
      # eth0: deleting route to fdb5:8d30:9e81:1::/64 via fe80::1691:38ff:fed0:2729
      #
      # Why is my router vomitting malformed DHCPv6 packets,
      # and killing networking?
      # Dumbest thing ever.
      extraConfig = ''
        nohook resolv.conf
        # Stop dhcpcd from ever requesting vendor class or FQDN
        nooption rapid_commit
        nooption vendorclassid
        nooption fqdn
        nooption 24
        nooption 25
      '';
      IPv6rs = true;
    };
    hostId = "bade5fb2";
    hostName = "nixos-hass";
    interfaces = {
      bond0.useDHCP = true;
    };
    nameservers = [
      "10.0.0.10"
      "75.75.75.75"
      "2601:406:8100:91D8:8EEC:4BFF:FE55:B2F1"
      "2001:558:FEED::1"
    ];
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