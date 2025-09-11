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
    services/toxvpn.nix
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
      label = "NIXOS_ROOT";
      fsType = "ext4";
    };
    "/boot" = {
      label = "NIXOS_BOOT";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
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
        9100 # Node Exporter
      ];
      allowedUDPPorts = [
        3700 # Peer port
        4101 # MC Server
        6990 # DHT
        51820 # Wireguard
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
        ${pkgs.iptables}/bin/iptables -D INPUT -p udp -j DROP
        ${pkgs.iptables}/bin/iptables -D INPUT -p udp -m limit --limit 10/second --limit-burst 10 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -D INPUT -p tcp --syn -m connlimit --connlimit-above 20 -j DROP
        ${pkgs.iptables}/bin/iptables -D INPUT -p tcp --syn -m limit --limit 10/second --limit-burst 50 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -D INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
        ${pkgs.iptables}/bin/iptables -D INPUT -m conntrack --ctstate INVALID -j DROP
      '';
    };
    hostName = "router";
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
      "1.0.0.1"
    ];
    useDHCP = false;
    usePredictableInterfaceNames = false;
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.hostPlatform = "x86_64-linux";

  security.acme = {
    acceptTerms = true;
    defaults.email = "diorcheats.vali@gmail.com";
  };

  swapDevices = [{
    device = "/var/lib/swap1";
    size = 1024;
  }];

  system.stateVersion = "25.11";
}
