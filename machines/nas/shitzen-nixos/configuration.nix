{ config
, lib
, pkgs
, modulesPath
, ... }:

{
  imports = [
    "${modulesPath}/installer/scan/not-detected.nix"

    boot/boot.nix

    modules/agenix.nix
    modules/nvidia.nix
    modules/wireguard.nix
    modules/wireguard-internal.nix

    services/chat/matrix.nix

    services/hydra/hydra.nix
    services/hydra/nix-options.nix

    services/filehosting/media/jellyfin.nix
    services/filehosting/media/kavita.nix

    services/filehosting/gitea-runner.nix
    services/filehosting/gitea.nix
    services/filehosting/nextcloud.nix
    services/filehosting/nfs.nix
    services/filehosting/samba.nix
    services/filehosting/zipline.nix

    #services/mail/roundcube.nix
    services/mail/server.nix
    services/mail/sogo.nix

    services/minecraft/default.nix

    services/monitoring/prometheus.nix
    services/monitoring/grafana.nix

    services/server/anubis.nix
    services/server/memcached.nix
    services/server/nginx.nix
    services/server/oauth2.nix

    services/sql/mysql.nix
    services/sql/postgresql.nix

    services/torrenting/arr/flaresolverr.nix
    services/torrenting/arr/lidarr.nix
    services/torrenting/arr/prowlarr.nix
    services/torrenting/arr/radarr.nix
    services/torrenting/arr/readarr.nix
    services/torrenting/arr/sonarr.nix

    services/torrenting/flood.nix
    services/torrenting/rtorrent-exporter.nix
    services/torrenting/rtorrent.nix

    services/virtualisation/dockge.nix

    #services/cloudpanel.nix
    #services/proxmox-nixos.nix
    services/toxvpn.nix
    services/ttyd.nix
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
  };

  environment.systemPackages = with pkgs; [
    btop
    dig
    efibootmgr
    ethtool
    fastfetch
    gdb
    git
    hdparm
    inetutils
    iperf
    jdk
    killall
    lshw
    lsof
    lsscsi
    usbutils
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
    # Better grep
    ripgrep
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
    dhcpcd.extraConfig = ''
      nohook resolv.conf
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
      enp3s0.useDHCP = true;
    };
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
      "2606:4700:4700::1111"
      "2001:4860:4860::8888"
    ];
    useDHCP = false;
  };

  services.kresd = {
    enable = lib.mkForce false;
    instances = 0;
  };

  nix.settings.keep-derivations = true;

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