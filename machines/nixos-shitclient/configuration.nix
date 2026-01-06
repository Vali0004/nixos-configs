{ config
, pkgs
, modulesPath
, ... }:

{
  imports = [
    "${modulesPath}/installer/scan/not-detected.nix"
    modules/boot.nix

    services/localnet.nix
    services/nginx.nix
    services/pihole.nix
    services/prometheus.nix
  ];

  acme.enable = true;

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
    # Ethernet tool
    ethtool
    # Version Tracking
    git
    # Internet Utilities
    inetutils
    # Internet performance monitoring
    iperf
    # Mini Certificate Authority
    minica
    # Mini COM
    minicom
    # Make Certificate
    mkcert
    # NCurses Disk usage
    ncdu
    # IPv6 Neighbor Discovery
    ndisc6
    # Network Tools
    net-tools
    # MBIM Tools
    libmbim
    # Open SSL
    openssl
    # PCI Utilies
    pciutils
    # Pico COM (sometimes easier than minicom)
    picocom
    # Power Joular - Monitor power usage
    powerjoular
    # Power Top - Tuning power usage
    powertop
    # Python - useful for some scripts
    python3
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
    intel.enable = true;
    # We have graphics support, might as well enable it; although, we don't need 32-bit support
    graphics.enable = true;
  };

  networking = {
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
    extraHosts = ''
      10.0.0.4 shitzen.localnet shitzen-nixos
      10.0.0.7 shitzen-kvm.localnet shitzen-nixos-kvm
      10.0.0.2 shitclient.localnet ${config.networking.hostName}
      10.0.0.3 nixos-hass.localnet nixos-hass
      10.0.0.2 hass.localnet ${config.networking.hostName}
      10.0.0.2 jellyfin.localnet ${config.networking.hostName}
      10.0.0.2 kvm.localnet ${config.networking.hostName}
      10.0.0.2 monitoring.localnet ${config.networking.hostName}
      10.0.0.2 pihole.localnet ${config.networking.hostName}
      10.0.0.2 zigbee2mqtt.localnet ${config.networking.hostName}
    '';
    firewall = {
      # DNS is open
      # SSH is open
      # Pihole is open
      allowedTCPPorts = [
        80 # HTTP
        443 # HTTPS
        5201 # iperf
      ];
      allowedUDPPorts = [
        5201 # iperf
      ];
    };
    hostId = "bade5fb2";
    hostName = "nixos-shitclient";
    interfaces = {
      eth0.useDHCP = true;
    };
    usePredictableInterfaceNames = false;
  };

  # Setup auto-tune by default
  powerManagement.powertop.enable = true;

  programs.zsh.enable = true;

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