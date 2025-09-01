{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./agenix.nix
  ];

  boot = {
    extraModulePackages = [ ];
    initrd = {
      availableKernelModules = [
        "ahci" # SATA
        "ata_piix"
        "virtio_blk"
        "virtio_pci"
        "virtio_pci_legacy_dev"
        "virtio_pci_modern_dev"
        "virtio_scsi"
        "uhci_hcd"
        "sd_mod"
        "sr_mod"
      ];
      kernelModules = [ ];
    };
    kernel.sysctl."net.ipv4.ip_forward" = true;
    kernel.sysctl."net.ipv4.tcp_syncookies" = true;
    kernel.sysctl."net.netfilter.nf_conntrack_max" = 25594;
    kernelModules = [ "kvm-amd" ];
    loader.grub = {
      configurationLimit = 3;
      copyKernels = true;
      device = "/dev/vda";
      efiSupport = false;
    };
  };

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
    wireguard-tools
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
      interface = "ens6";
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
        6667 # IRC
        6697 # IRCS
      ];
      allowedUDPPorts = [
        3700 # Peer port
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
    interfaces.ens6 = {
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
    nat = {
      enable = true;
      enableIPv6 = true;
      externalInterface = "ens6";
      internalInterfaces = [ "wg0" ];
    };
    useDHCP = false;
    wireguard = {
      enable = true;
      interfaces.wg0 = {
        ips = [ "10.127.0.1/24" ];
        listenPort = 51820;
        postSetup = ''
          ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.127.0.0/24 -o ens6 -j MASQUERADE

          ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.127.0.0/24 -o ens6 -p udp -j MASQUERADE

          ${pkgs.iptables}/bin/iptables -t nat -A PREROUTING -i ens6 -p tcp --dport 25 -j DNAT --to-destination 10.127.0.3:25
          ${pkgs.iptables}/bin/iptables -t nat -A PREROUTING -i ens6 -p tcp --dport 80 -j DNAT --to-destination 10.127.0.3:80
          ${pkgs.iptables}/bin/iptables -t nat -A PREROUTING -i ens6 -p tcp --dport 443 -j DNAT --to-destination 10.127.0.3:443
          ${pkgs.iptables}/bin/iptables -t nat -A PREROUTING -i ens6 -p tcp --dport 465 -j DNAT --to-destination 10.127.0.3:465
          ${pkgs.iptables}/bin/iptables -t nat -A PREROUTING -i ens6 -p tcp --dport 587 -j DNAT --to-destination 10.127.0.3:587
          ${pkgs.iptables}/bin/iptables -t nat -A PREROUTING -i ens6 -p tcp --dport 993 -j DNAT --to-destination 10.127.0.3:993
          ${pkgs.iptables}/bin/iptables -t nat -A PREROUTING -i ens6 -p tcp --dport 995 -j DNAT --to-destination 10.127.0.3:995
          ${pkgs.iptables}/bin/iptables -t nat -A PREROUTING -i ens6 -p tcp --dport 3700 -j DNAT --to-destination 10.127.0.3:3700
          ${pkgs.iptables}/bin/iptables -t nat -A PREROUTING -i ens6 -p tcp --dport 6667 -j DNAT --to-destination 10.127.0.3:6667
          ${pkgs.iptables}/bin/iptables -t nat -A PREROUTING -i ens6 -p tcp --dport 6697 -j DNAT --to-destination 10.127.0.3:6697
          ${pkgs.iptables}/bin/iptables -t nat -A PREROUTING -i ens6 -p udp --dport 3700 -j DNAT --to-destination 10.127.0.3:3700
          ${pkgs.iptables}/bin/iptables -t nat -A PREROUTING -i ens6 -p udp --dport 6990 -j DNAT --to-destination 10.127.0.3:6990

          ${pkgs.iptables}/bin/iptables -A FORWARD -s 10.127.0.0/24 -p tcp -j ACCEPT
          ${pkgs.iptables}/bin/iptables -A FORWARD -d 10.127.0.0/24 -p tcp -j ACCEPT

          ${pkgs.iptables}/bin/iptables -A FORWARD -s 10.127.0.0/24 -p udp -j ACCEPT
          ${pkgs.iptables}/bin/iptables -A FORWARD -d 10.127.0.0/24 -p udp -j ACCEPT

          ${pkgs.iptables}/bin/iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
          ${pkgs.iptables}/bin/iptables -A FORWARD -s 10.127.0.0/24 -j ACCEPT
        '';
        postShutdown = ''
          ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.127.0.0/24 -o ens6 -j MASQUERADE

          ${pkgs.iptables}/bin/iptables -t nat -D PREROUTING -i ens6 -p tcp --dport 25 -j DNAT --to-destination 10.127.0.3:25
          ${pkgs.iptables}/bin/iptables -t nat -D PREROUTING -i ens6 -p tcp --dport 80 -j DNAT --to-destination 10.127.0.3:80
          ${pkgs.iptables}/bin/iptables -t nat -D PREROUTING -i ens6 -p tcp --dport 443 -j DNAT --to-destination 10.127.0.3:443
          ${pkgs.iptables}/bin/iptables -t nat -D PREROUTING -i ens6 -p tcp --dport 465 -j DNAT --to-destination 10.127.0.3:465
          ${pkgs.iptables}/bin/iptables -t nat -D PREROUTING -i ens6 -p tcp --dport 587 -j DNAT --to-destination 10.127.0.3:587
          ${pkgs.iptables}/bin/iptables -t nat -D PREROUTING -i ens6 -p tcp --dport 993 -j DNAT --to-destination 10.127.0.3:993
          ${pkgs.iptables}/bin/iptables -t nat -D PREROUTING -i ens6 -p tcp --dport 995 -j DNAT --to-destination 10.127.0.3:995
          ${pkgs.iptables}/bin/iptables -t nat -D PREROUTING -i ens6 -p tcp --dport 3700 -j DNAT --to-destination 10.127.0.3:3700
          ${pkgs.iptables}/bin/iptables -t nat -D PREROUTING -i ens6 -p tcp --dport 6667 -j DNAT --to-destination 10.127.0.3:6667
          ${pkgs.iptables}/bin/iptables -t nat -D PREROUTING -i ens6 -p tcp --dport 6697 -j DNAT --to-destination 10.127.0.3:6697
          ${pkgs.iptables}/bin/iptables -t nat -D PREROUTING -i ens6 -p udp --dport 3700 -j DNAT --to-destination 10.127.0.3:3700
          ${pkgs.iptables}/bin/iptables -t nat -D PREROUTING -i ens6 -p udp --dport 6990 -j DNAT --to-destination 10.127.0.3:6990

          ${pkgs.iptables}/bin/iptables -D FORWARD -s 10.127.0.0/24 -p tcp -j ACCEPT
          ${pkgs.iptables}/bin/iptables -D FORWARD -d 10.127.0.0/24 -p tcp -j ACCEPT

          ${pkgs.iptables}/bin/iptables -D FORWARD -s 10.127.0.0/24 -p udp -j ACCEPT
          ${pkgs.iptables}/bin/iptables -D FORWARD -d 10.127.0.0/24 -p udp -j ACCEPT

          ${pkgs.iptables}/bin/iptables -D FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
          ${pkgs.iptables}/bin/iptables -D FORWARD -s 10.127.0.0/24 -j ACCEPT
        '';
        privateKeyFile = config.age.secrets.wireguard-server.path;
        peers = [{
          allowedIPs = [ "10.127.0.3/32" ];
          publicKey = "TekfTYyHo+PsZRFLHopuw3/aBFe6/H3+ZaTLIg4mg24=";
        }];
      };
    };
  };

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
  };

  nixpkgs = {
    hostPlatform = "x86_64-linux";
  };

  services = {
    toxvpn = {
      localip = "10.0.127.1";
      auto_add_peers = [
        "3e24792c18ab55c59974a356e2195f165e0d967726533818e5ac0361b264ea671d1b3a8ec221" # shitzen
      ];
    };
  };

  swapDevices = [{
    device = "/var/lib/swap1";
    size = 1024;
  }];

  system.stateVersion = "25.05";
}
