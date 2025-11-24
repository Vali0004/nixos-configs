{ pkgs
, modulesPath
, ... }:

{
  imports = [
    "${modulesPath}/profiles/qemu-guest.nix"
    modules/status.nix
    modules/agenix.nix
    modules/boot.nix
    #modules/wireguard.nix

    services/virtualisation/dockge.nix
    services/nginx.nix
    services/prometheus.nix
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
    radvd
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
      fsType = "vfat";
      label = "NIXOS_BOOT";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };
  };

  networking = {
    defaultGateway = "23.143.108.1";
    #defaultGateway6 = {
    #  address = "fe80::1";
    #  interface = "eth0";
    #};
    firewall = {
      allowedTCPPorts = [
        80 # HTTP
        443 # HTTPS
        #3700 # Peer port
        9101 # Node Exporter
        9192 # XDP
      ];
      allowedUDPPorts = [
        #3700 # Peer port
        #6990 # DHT
      ];
    };
    hostId = "eca03077";
    hostName = "router-vps-v2";
    interfaces.eth0 = {
      ipv4.addresses = [{
        address = "23.143.108.18";
        prefixLength = 24;
      }];
      useDHCP = true;
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
}