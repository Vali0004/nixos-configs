{ config, inputs, lib, pkgs, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/installer/scan/not-detected.nix"
    modules/cors-anywhere/service.nix
    modules/pnp-loader/service.nix

    modules/agenix.nix

    modules/boot.nix
    modules/dockge.nix
    modules/wireguard.nix
    modules/zfs.nix

    services/arr/prowlarr.nix
    services/arr/radarr.nix
    services/arr/sonarr.nix
    services/minecraft/package.nix

    services/hydra.nix
    services/jellyfin.nix
    services/mailserver.nix

    services/mysql.nix
    services/nfs.nix
    services/nginx.nix
    services/oauth2.nix

    services/postgresql.nix

    services/rtorrent.nix
    services/samba.nix

    services/zipline.nix
  ];

  environment.systemPackages = with pkgs; [
    btop
    dig
    docker-compose
    fastfetch
    ffmpeg_6-headless
    git
    hdparm
    iperf
    jdk
    lsof
    lsscsi
    magic-wormhole
    mediainfo
    mysql84
    node2nix
    openssl
    pciutils
    redis
    screen
    sg3_utils
    smartmontools
    tmux
    tshark
    unzip
    wget
    wings
    zip
  ];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/9ffafbc0-8e3a-4f71-80e8-c9f225398340";
      fsType = "ext4";
      options = [ "data=journal" ];
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/9E79-76DF";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };
    "/data" = {
      device = "zpool/data";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };
  };

  hardware.cpu.amd.updateMicrocode = config.hardware.enableRedistributableFirmware;

  minecraft.prod = false;

  networking = {
    defaultGateway = "10.0.0.1";
    firewall = {
      # SSH is also open, and so is rtorrent
      allowedTCPPorts = [
        25 # SMTP
        80 # HTTP
        443 # HTTPS
        465 # SMTPS
        587 # SMTP (with STARTTLS)
        993 # IMAPS
        995 # SPOP3
        5201 # iperf
      ];
      allowedUDPPorts = [
        5201 # iperf
      ];
    };
    hostId = "0626c0ac";
    hostName = "shitzen-nixos";
    interfaces.enp7s0 = {
      ipv4.addresses = [{
        address = "10.0.0.244";
        prefixLength = 24;
      }];
      ipv6.addresses = [
        {
          address = "2601:406:8401:5310::31d";
          prefixLength = 128;
        }
        {
          address = "2601:406:8401:5310:dd29:e01c:f563:9898";
          prefixLength = 64;
        }
        {
          address = "2601:406:8401:5310:62cf:84ff:fe5e:82bb";
          prefixLength = 64;
        }
        {
          address = "fe80::62cf:84ff:fe5e:82bb";
          prefixLength = 64;
        }
      ];
    };
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
    ];
    networkmanager.dns = "none";
    resolvconf.useLocalResolver = false;
    useDHCP = false;
  };

  nix.settings = {
    cores = 1;
    keep-derivations = true;
    max-jobs = 1;
    max-substitution-jobs = 8;
  };

  nixpkgs = {
    config.allowUnfree = true;
    hostPlatform = "x86_64-linux";
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "diorcheats.vali@gmail.com";
  };

  services.toxvpn = {
    auto_add_peers = [
      "12f5850c8664f0ad12047ac2347ef8b1bfb8d26cd37a795c4f7c590cd6b87e7c6b96ca1c9df5" # router
    ];
    localip = "10.0.127.3";
  };

  swapDevices = [{
    device = "/var/lib/swap1";
    size = 8192;
  }];

  system.stateVersion = "25.11";
}
