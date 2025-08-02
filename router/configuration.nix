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
    kernelModules = [ "kvm-amd" ];
    loader.grub = {
      configurationLimit = 3;
      copyKernels = true;
      device = "/dev/vda";
      efiSupport = false;
    };
  };

  environment.systemPackages = with pkgs; [
    fastfetch
    ffmpeg_6-headless
    git
    htop
    iperf
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
    firewall = {
      allowedTCPPorts = [
        25 # SMTP
        80 # HTTP
        443 # HTTPS
        465 # SMTPS
        587 # SMTP (with STARTTLS)
        993 # IMAPS
        995 # SPOP3
      ];
      allowedUDPPorts = [
        51820 # Wireguard
      ];
    };
    hostName = "router";
    interfaces.ens6 = {
      ipv4.addresses = [{
        address = "74.208.44.130";
        prefixLength = 24;
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
          ${pkgs.iptables}/bin/iptables -t nat -A PREROUTING -i ens6 -p udp --dport 6990 -j DNAT --to-destination 10.127.0.3:6990

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
          ${pkgs.iptables}/bin/iptables -t nat -D PREROUTING -i ens6 -p udp --dport 6990 -j DNAT --to-destination 10.127.0.3:6990

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
