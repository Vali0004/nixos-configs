{ pkgs
, modulesPath
, ... }:

{
  imports = [
    "${modulesPath}/profiles/qemu-guest.nix"
    modules/status.nix
    modules/agenix.nix
    modules/boot.nix
    modules/wireguard.nix

    services/nginx.nix
    services/prometheus.nix
    services/xdp.nix
  ];

  environment.systemPackages = with pkgs; [
    conntrack-tools
    fastfetch
    gdb
    git
    htop
    inetutils
    iperf
    minica
    ncdu
    ndisc6
    net-tools
    openssl
    screen
    tcpdump
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
      fsType = "ext4";
    };
  };

  networking = {
    defaultGateway = "74.208.44.1";
    defaultGateway6 = {
      address = "fe80::1";
      interface = "eth0";
    };
    firewall = {
      allowedTCPPorts = [
        25 # SMTP
        80 # HTTP
        443 # HTTPS
        465 # SMTPS
        587 # SMTP (with STARTTLS)
        993 # IMAPS
        995 # SPOP3
        3700 # Peer port
        4100 # MC Server
        6667 # IRC
        6697 # IRCS
        8080 # TOR
        9101 # Node Exporter
        9192 # XDP
      ];
      allowedUDPPorts = [
        3700 # Peer port
        4101 # MC Server
        6990 # DHT
      ];
    };
    hostId = "eca03077";
    hostName = "router-vps";
    interfaces.eth0 = {
      ipv4.addresses = [{
        address = "74.208.44.130";
        prefixLength = 24;
      }];
      ipv6.addresses = [{
        address = "2607:f1c0:f088:e200::1";
        prefixLength = 80;
      }];
    };
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
      "2001:4860:4860::8888"
      "2606:4700:4700::1111"
    ];
    useDHCP = false;
    usePredictableInterfaceNames = false;
  };

  acme.enable = true;

  swapDevices = [{
    device = "/dev/disk/by-label/NIXOS_SWAP";
  }];

  zfs.fragmentation = {
    enable = true;
    openFirewall = true;
  };
}