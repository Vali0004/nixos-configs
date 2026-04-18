{ config
, lib
, pkgs
, ... }:

let
  my_keys = import ./ssh_keys_personal.nix;
in {
  imports = [
    ./modules/services/fail2ban.nix
    ./modules/services/openssh.nix
    ./modules/imports.nix
  ];

  environment.systemPackages = with pkgs; [
    config.services.chrony.package
    # Binary Tools
    bintools
    # Better TOP
    btop
    # Connection tracking tools
    conntrack-tools
    # cURL
    curl
    # Ethernet tool
    ethtool
    # Version Tracking
    git
    # Modern neofetch
    fastfetch
    # Internet Utilities
    inetutils
    # Internet performance monitoring
    iperf
    # NCurses Disk usage
    ncdu
    # IPv6 Neighbor Discovery
    ndisc6
    # Network Tools
    net-tools
    # List Hardware
    lshw
    # Partition utility
    parted
    # PCI Utilies
    pciutils
    # Ookla Native Speedtest
    speedtest
    # TCP Dump
    tcpdump
    # USB Utilies
    usbutils
    # Web Get
    wget
  ];

  hardware = {
    enableKvm = true;
    enableRedistributableFirmware = true;
  };

  networking.timeServers = [
    "0.pool.ntp.org"
    "1.pool.ntp.org"
    "2.pool.ntp.org"
    "3.pool.ntp.org"
  ];

  nixops-deploy.enable = true;

  services = {
    chrony = {
      enable = true;
      enableRTCTrimming = true;
    };
    ntp.enable = false;
    timesyncd.enable = false;
    vnstat.enable = true;
  };

  users.users = let
    common_keys = import ./ssh_keys.nix;
  in {
    root = {
      openssh.authorizedKeys.keys = my_keys ++ common_keys;
    };
    vali = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = my_keys ++ common_keys;
    };
  };

  zfs = {
    fragmentation = lib.mkIf config.zfs.enable {
      enable = true;
      openFirewall = lib.mkDefault true;
    };
    enable = lib.mkDefault true;
  };
}
