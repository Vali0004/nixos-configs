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
    # Useful for DNS debugging
    dig
    # Display Mode Info Decode
    dmidecode
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
    # List Hardware
    lshw
    # Open SSL
    openssl
    # Partition utility
    parted
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
    fragmentation = {
      enable = true;
      openFirewall = lib.mkDefault true;
    };
    enable = true;
  };
}
