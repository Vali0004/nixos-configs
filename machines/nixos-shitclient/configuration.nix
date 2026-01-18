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
    # Useful for DNS debugging
    dig
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
    # We'b Get
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
    "/mnt/data" = {
      device = "10.0.0.4:/data";
      fsType = "nfs";
      options = [ "x-systemd.automount" "noauto" "soft" ];
    };
  };

  hardware = {
    intel.enable = true;
    # We have graphics support, might as well enable it; although, we don't need 32-bit support
    graphics.enable = true;
  };

  networking = {
    extraHosts = ''
      10.0.0.4 shitzen.localnet shitzen-nixos
      10.0.0.5 shitzen-kvm.localnet shitzen-nixos-kvm
      10.0.0.2 shitclient.localnet ${config.networking.hostName}
      10.0.0.3 nixos-hass.localnet nixos-hass
      10.0.0.2 hass.localnet ${config.networking.hostName}
      10.0.0.2 jellyfin.localnet ${config.networking.hostName}
      10.0.0.2 kvm.localnet ${config.networking.hostName}
      10.0.0.2 monitoring.localnet ${config.networking.hostName}
      10.0.0.2 rtorrent.localnet ${config.networking.hostName}
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