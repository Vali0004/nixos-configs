{ config
, lib
, pkgs
, ... }:

{
  services.flood = {
    enable = true;
    host = "0.0.0.0";
    port = 3702;
    openFirewall = true;
    extraArgs = [
      "--rtsocket=${config.services.rtorrent.rpcSocket}"
    ];
  };

  systemd.services.flood-private = {
    description = "Flood (private)";
    after = [ "network-online.target" "rtorrent-private.service" ];
    wants = [ "network-online.target" "rtorrent-private.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      User = config.services.rtorrent.user;
      Group = config.services.rtorrent.group;
      Environment = "HOME=/var/lib/flood-private";
      WorkingDirectory = "/var/lib/flood-private";

      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p /var/lib/flood-private";
      ExecStart = "${pkgs.flood}/bin/flood --host 0.0.0.0 --port ${toString (config.services.flood.port + 1)} --rtsocket=/run/rtorrent-private/rpc.sock";

      Restart = "on-failure";

      ReadWritePaths = [
        "/var/lib/flood-private"
        "/data/private/Media"
        "/data/services/downloads"
      ];
      SupplementaryGroups = [ config.services.rtorrent.group ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/flood-private 0755 ${config.services.rtorrent.user} ${config.services.rtorrent.group} - -"
  ];

  services.nginx.virtualHosts."flood.kursu.dev" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = lib.mkProxy {
      ip = "192.168.100.1";
      port = config.services.flood.port;
    };
  };

  services.nginx.virtualHosts."flood-private.kursu.dev" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = lib.mkProxy {
      ip = "192.168.100.1";
      port = config.services.flood.port + 1;
    };
  };

  systemd.services.flood.serviceConfig = {
    Environment = "HOME=/var/lib/flood";
    Group = config.services.rtorrent.group;
    ReadWritePaths = [
      "/var/lib/flood"
      "/data/private/Media"
      "/data/services/downloads"
    ];
    SupplementaryGroups = [
      config.services.rtorrent.group
    ];
    User = config.services.rtorrent.user;
  };
}