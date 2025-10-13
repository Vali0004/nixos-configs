{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/profiles/qemu-guest.nix"
    modules/status/service.nix
    modules/agenix.nix
    modules/boot.nix
    modules/wireguard.nix

    services/nginx.nix
    services/prometheus.nix
  ];

  environment.systemPackages = with pkgs; [
    conntrack-tools
    fastfetch
    git
    htop
    inetutils
    iperf
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
      ];
      allowedUDPPorts = [
        3700 # Peer port
        4101 # MC Server
        6990 # DHT
      ];
      extraCommands = ''
        # Drop invalid connection states
        ${pkgs.iptables}/bin/iptables -A INPUT -m conntrack --ctstate INVALID -j DROP

        # Allow existing/related connections
        ${pkgs.iptables}/bin/iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

        # Rate-limit new TCP SYN connections
        ${pkgs.iptables}/bin/iptables -A INPUT -p tcp --syn -m limit --limit 10/second --limit-burst 50 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -A INPUT -p tcp --syn -m connlimit --connlimit-above 20 -j DROP

        # UDP: allow limited rate
        ${pkgs.iptables}/bin/iptables -A INPUT -p udp -m limit --limit 10/second --limit-burst 10 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -A INPUT -p udp -j DROP
      '';
      extraStopCommands = ''
        ${pkgs.iptables}/bin/iptables -D INPUT -p udp -j DROP || true
        ${pkgs.iptables}/bin/iptables -D INPUT -p udp -m limit --limit 10/second --limit-burst 10 -j ACCEPT || true
        ${pkgs.iptables}/bin/iptables -D INPUT -p tcp --syn -m connlimit --connlimit-above 20 -j DROP || true
        ${pkgs.iptables}/bin/iptables -D INPUT -p tcp --syn -m limit --limit 10/second --limit-burst 50 -j ACCEPT || true
        ${pkgs.iptables}/bin/iptables -D INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT || true
        ${pkgs.iptables}/bin/iptables -D INPUT -m conntrack --ctstate INVALID -j DROP || true
      '';
    };
    hostId = "eca03077";
    hostName = "router-vps";
    useDHCP = true;
    usePredictableInterfaceNames = false;
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "diorcheats.vali@gmail.com";
  };

  swapDevices = [{
    device = "/dev/disk/by-label/NIXOS_SWAP";
    size = 512;
  }];

  system.stateVersion = "25.11";
}
