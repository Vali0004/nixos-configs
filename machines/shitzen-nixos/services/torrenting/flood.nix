{ config
, pkgs
, lib
, ... }:

{
  services.flood = {
    enable = true;
    host = "0.0.0.0";
    port = 3701;
    openFirewall = true;
    extraArgs = [
      "--rtsocket=${config.services.rtorrent.rpcSocket}"
    ];
  };

  services.nginx.virtualHosts."flood.fuckk.lol" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = lib.mkProxy {
      port = config.services.flood.port;
    };
  };

  systemd.services.flood.serviceConfig = {
    Environment = "HOME=/var/lib/flood";
    Group = "rtorrent";
    ReadWritePaths = [
      "/var/lib/flood"
      "/data/private/Media"
      "/data/services/downloads"
    ];
    SupplementaryGroups = [
      config.services.rtorrent.group
    ];
    User = "rtorrent";
  };
}