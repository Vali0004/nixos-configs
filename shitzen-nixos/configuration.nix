{ config, inputs, lib, pkgs, modulesPath, ... }:

let
  mkNamespace = import ./modules/mknamespace.nix;
in {
  imports = [
    "${modulesPath}/installer/scan/not-detected.nix"
    modules/cors-anywhere/service.nix

    modules/pnp-loader/api/service.nix
    modules/pnp-loader/backend/service.nix
    modules/pnp-loader/dashboard/service.nix

    modules/agenix.nix

    modules/boot.nix
    #modules/dockge.nix
    modules/nvidia.nix
    modules/wireguard.nix
    modules/zfs-patch.nix
    modules/zfs.nix

    services/grafana/module.nix
    services/grafana/prometheus.nix

    services/arr/flaresolverr.nix
    services/arr/prowlarr.nix
    services/arr/radarr.nix
    services/arr/sonarr.nix

    services/minecraft/package.nix

    services/rtorrent-exporter/service.nix

    services/anubis.nix
    services/hydra.nix
    services/irc.nix
    services/jellyfin.nix
    services/mailserver.nix

    services/matrix.nix
    services/mysql.nix
    services/nfs.nix
    services/nginx.nix
    services/oauth2.nix

    services/postgresql.nix

    services/rtorrent.nix
    services/samba.nix

    services/toxvpn.nix
    services/zdb.nix
    services/zipline.nix
  ];

  systemd.services.dovecot.serviceConfig = mkNamespace {};

  systemd.services.inspircd.serviceConfig = mkNamespace {};

  systemd.services.matrix-synapse.serviceConfig = mkNamespace {};

  systemd.services.nginx.serviceConfig = mkNamespace {};
  systemd.services.oauth2-proxy.serviceConfig = mkNamespace {};

  systemd.services.postfix.serviceConfig = mkNamespace {};
  systemd.services.rspamd.serviceConfig = mkNamespace {};

  systemd.services.rtorrent.serviceConfig = mkNamespace {};

  environment.systemPackages = with pkgs; [
    btop
    dig
    efibootmgr
    fastfetch
    git
    hdparm
    iperf
    jdk
    lshw
    lsof
    lsscsi
    magic-wormhole
    mediainfo
    ncdu
    net-tools
    openssl
    pciutils
    powerjoular
    redis
    screen
    sg3_utils
    sqlite-interactive
    smartmontools
    tmux
    tshark
    unzip
    wget
    zip
    mesa
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
      options = [ "zfsutil" "nofail" ];
    };
  };

  hardware = {
    cpu.amd.updateMicrocode = config.hardware.enableRedistributableFirmware;
    enableRedistributableFirmware = true;
  };

  minecraft.prod = true;

  networking = {
    defaultGateway = "10.0.0.1";
    defaultGateway6 = {
      address = "fe80::1";
      interface = "eth0";
    };
    firewall = {
      # SMTP is open
      # SMTPS is open
      # SMTP (with STARTTLS) is open
      # IMAPS is open
      # SPOP3 is open
      # SSH is open
      # rtorrent is open
      allowedTCPPorts = [
        80 # HTTP
        443 # HTTPS
        5201 # iperf
      ];
      allowedUDPPorts = [
        5201 # iperf
      ];
    };
    hostId = "0626c0ac";
    hostName = "shitzen-nixos";
    interfaces.eth0 = {
      ipv4.addresses = [{
        address = "10.0.0.244";
        prefixLength = 24;
      }];
      ipv6.addresses = [
        {
          address = "2601:406:8400:42A3::31d";
          prefixLength = 128;
        }
        {
          address = "2601:406:8400:42A3:6d99:9295:f86a:98eb";
          prefixLength = 64;
        }
        {
          address = "fe80::62cf:84ff:fe5e:82bb";
          prefixLength = 64;
        }
      ];
    };
    nameservers = [
      "75.75.75.75"
      "75.75.76.76"
    ];
    networkmanager.dns = "none";
    resolvconf.useLocalResolver = false;
    useDHCP = false;
    usePredictableInterfaceNames = false;
  };

  nix.settings = {
    cores = 1;
    keep-derivations = true;
    max-jobs = 1;
    max-substitution-jobs = 1;
  };

  nixpkgs = {
    config.allowUnfree = true;
    hostPlatform = "x86_64-linux";
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "diorcheats.vali@gmail.com";
  };

  swapDevices = [{
    device = "/var/lib/swap1";
    size = 1024;
  }];

  system.stateVersion = "25.11";

  users.users.vali.extraGroups = [ "video" "render" ];
}
