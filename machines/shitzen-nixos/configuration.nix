{ config, inputs, lib, pkgs, modulesPath, ... }:

let
  mkNamespace = import ./modules/mknamespace.nix;
in {
  imports = [
    "${modulesPath}/installer/scan/not-detected.nix"
    ajax-container/module.nix

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

    services/arr/flaresolverr.nix
    services/arr/prowlarr.nix
    services/arr/radarr.nix
    services/arr/readarr.nix
    services/arr/sonarr.nix

    services/minecraft/package.nix

    services/rtorrent-exporter/service.nix

    services/anubis.nix
    services/hydra.nix
    services/ist.nix
    services/irc.nix
    services/jellyfin.nix
    services/kavita.nix
    services/mailserver.nix

    services/matrix.nix
    services/mysql.nix
    services/nfs.nix
    services/nginx.nix
    services/oauth2.nix
    services/pihole.nix

    services/postgresql.nix
    services/prometheus.nix

    services/rtorrent.nix
    services/samba.nix

    services/tor.nix
    services/ttyd.nix
    services/zdb.nix
    services/zipline.nix
  ];

  systemd.services.dovecot.serviceConfig = mkNamespace {};

  systemd.services.inspircd.serviceConfig = mkNamespace {};

  systemd.services.matrix-synapse.serviceConfig = mkNamespace {};

  systemd.services.minecraft-server-prod.serviceConfig = mkNamespace {};

  systemd.services.nginx.serviceConfig = mkNamespace {};
  systemd.services.oauth2-proxy.serviceConfig = mkNamespace {};

  systemd.services.postfix.serviceConfig = mkNamespace {};
  systemd.services.postfix-setup.serviceConfig = mkNamespace {};
  systemd.services.rspamd.serviceConfig = mkNamespace {};

  systemd.services.rtorrent.serviceConfig = mkNamespace {};
  systemd.services.flood.serviceConfig = mkNamespace {};

  systemd.services.tor.serviceConfig = mkNamespace {};

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
    killall
    magic-wormhole
    mediainfo
    mkp224o
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
    extraHosts = ''
      10.0.0.244 jellyfin.localnet jellyfin
      10.0.0.244 pihole.localnet pihole
    '';
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
    networkmanager.dns = "none";
    resolvconf.useLocalResolver = false;
    useDHCP = true;
    nameservers = [
      "8.8.8.8"
      "1.1.1.1"
      "1.0.0.1"
    ];
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

  system.stateVersion = "25.11";

  users.users.vali.extraGroups = [ "video" "render" ];
}
