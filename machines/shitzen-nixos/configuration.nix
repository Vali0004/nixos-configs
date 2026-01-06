{ config
, lib
, pkgs
, modulesPath
, ... }:

{
  imports = [
    "${modulesPath}/installer/scan/not-detected.nix"
    ajax-container/module.nix

    boot/boot.nix

    modules/agenix.nix
    modules/nvidia.nix
    modules/wireguard.nix

    services/hydra/hydra.nix
    services/hydra/nix-options.nix

    services/filehosting/nfs.nix
    services/filehosting/samba.nix

    services/minecraft/default.nix

    services/monitoring/prometheus.nix
    services/monitoring/grafana.nix

    services/sql/mysql.nix
    services/sql/postgresql.nix

    services/torrenting/arr/flaresolverr.nix
    services/torrenting/arr/prowlarr.nix
    services/torrenting/arr/radarr.nix
    services/torrenting/arr/readarr.nix
    services/torrenting/arr/sonarr.nix

    services/torrenting/flood.nix
    services/torrenting/rtorrent-exporter.nix
    services/torrenting/rtorrent.nix

    services/virtualisation/dockge.nix

    services/web/chat/matrix.nix

    services/web/filehosting/media/jellyfin.nix
    services/web/filehosting/media/kavita.nix
    services/web/filehosting/gitea.nix
    services/web/filehosting/nextcloud.nix
    services/web/filehosting/zipline.nix

    services/web/server/anubis.nix
    services/web/server/memcached.nix
    services/web/server/nginx.nix
    services/web/server/oauth2.nix

    #services/web/mail/roundcube.nix
    services/web/mail/server.nix
    services/web/mail/sogo.nix

    services/web/tor.nix
    services/web/ttyd.nix

    #services/web/whmcs.nix

    services/wireguard.nix
    services/toxvpn.nix
  ];

  systemd.services = {
    dovecot.serviceConfig = lib.mkNamespace {};
    matrix-synapse.serviceConfig = lib.mkNamespace {};
    minecraft-server-prod = lib.mkIf config.minecraft.prod {
      serviceConfig = lib.mkNamespace {};
    };
    nginx.serviceConfig = lib.mkNamespace {};
    oauth2-proxy.serviceConfig = lib.mkNamespace {};
    postfix.serviceConfig = lib.mkNamespace {};
    postfix-setup.serviceConfig = lib.mkNamespace {};
    rspamd.serviceConfig = lib.mkNamespace {};
    rtorrent.serviceConfig = lib.mkNamespace {};
    tor.serviceConfig = lib.mkNamespace {};
  };

  environment.systemPackages = with pkgs; [
    btop
    dig
    efibootmgr
    ethtool
    fastfetch
    git
    hdparm
    inetutils
    iperf
    jdk
    killall
    lshw
    lsof
    lsscsi
    magic-wormhole
    mediainfo
    memtester
    minica
    mkp224o
    ncdu
    net-tools
    # ndisc - used for RAs
    ndisc6
    nmap
    openssl
    pciutils
    powerjoular
    powertop
    redis
    screen
    sg3_utils
    sqlite-interactive
    smartmontools
    tmux
    traceroute
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

  hardware.amd.enable = true;

  networking = {
    dhcpcd = {
      # TP-Link is stupid...
      #
      # eth0: adding route to fdb5:8d30:9e81:1::/64 via fe80::1691:38ff:fed0:2729
      # eth0: dhcp_envoption 24.0/3: malformed embedded option
      # eth0: deleting route to fdb5:8d30:9e81:1::/64 via fe80::1691:38ff:fed0:2729
      #
      # Why is my router vomitting malformed DHCPv6 packets,
      # and killing networking?
      # Dumbest thing ever.
      extraConfig = ''
        # Stop dhcpcd from ever requesting vendor class or FQDN
        nooption rapid_commit
        nooption vendorclassid
        nooption fqdn
        nooption 24
        nooption 25
      '';
      IPv6rs = true;
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
        5000 # OnTheSpot
        5201 # iperf
      ];
      allowedUDPPorts = [
        5201 # iperf
      ];
    };
    hostId = "0626c0ac";
    hostName = "shitzen-nixos";
    interfaces = {
      eth0.useDHCP = true;
      enp4s0.useDHCP = false;
    };
    useDHCP = false;
    usePredictableInterfaceNames = true;
  };

  nix.settings.keep-derivations = true;

  # Setup auto-tune by default
  powerManagement.powertop.enable = true;

  acme.enable = true;

  swapDevices = [{
    device = "/var/lib/swap";
    size = 16384;
  }];

  users.users = {
    vali.extraGroups = [ "video" "render" ];
    root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGWxSLK5fZYYfrGT/B0trFhaToJYtoUp+GsAy9a/e2Mo"
    ];
  };

  zfs.autoSnapshot.enable = true;
}