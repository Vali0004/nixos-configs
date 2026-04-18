{ pkgs
, modulesPath
, ... }:

let
  homeV4 = "76.112.236.206";
  homeV6 = "2601:406:8180:35a7";
in {
  imports = [
    "${modulesPath}/profiles/qemu-guest.nix"
    modules/agenix.nix
    modules/boot.nix
    modules/wireguard.nix

    services/prometheus.nix
  ];

  acme.enable = true;

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
    nload
    net-tools
    nmap
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
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };
  };

  networking = {
    defaultGateway = "23.143.108.1";
    defaultGateway6 = {
      address = "fe80::be24:11ff:fe2a:a736";
      interface = "eth0";
      metric = 1024;
    };
    firewall = {
      allowedTCPPorts = [
        25 # SMTP
        143 # IMAP
        465 # SMTPS
        587 # SMTP (with STARTTLS)
        993 # IMAPS
        995 # SPOP3
      ];
      extraCommands = ''
        for x in 9100 9103 9134 9586 9633; do
          ${pkgs.iptables}/bin/iptables -I INPUT -p tcp --dport $x -s ${homeV4} -j ACCEPT
          ${pkgs.iptables}/bin/iptables -A INPUT -p tcp --dport $x -j DROP
          ${pkgs.iptables}/bin/ip6tables -I INPUT -p tcp --dport $x -s ${homeV6}::1 -j ACCEPT
          ${pkgs.iptables}/bin/ip6tables -A INPUT -p tcp --dport $x -j DROP
        done
      '';
      extraStopCommands = ''
        for x in 9100 9103 9134 9586 9633; do
          ${pkgs.iptables}/bin/iptables -D INPUT -p tcp --dport $x -s ${homeV4}-j ACCEPT 2>/dev/null || true
          ${pkgs.iptables}/bin/iptables -D INPUT -p tcp --dport $x -j DROP 2>/dev/null || true
          ${pkgs.iptables}/bin/ip6tables -D INPUT -p tcp --dport $x -s ${homeV6}::1 -j ACCEPT 2>/dev/null || true
          ${pkgs.iptables}/bin/ip6tables -D INPUT -p tcp --dport $x -j DROP 2>/dev/null || true
        done
      '';
    };
    hostId = "eca03077";
    hostName = "nas-mail-exitnode";
    interfaces.eth0 = {
      ipv4.addresses = [{
        address = "23.143.108.40";
        prefixLength = 24;
      }];
      ipv6.addresses = [{
        address = "2602:f5c6:0:af:94cb:8a:1115:32ae";
        prefixLength = 56;
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

  swapDevices = [{
    device = "/dev/disk/by-label/NIXOS_SWAP";
  }];

  zfs.fragmentation.openFirewall = false;
}