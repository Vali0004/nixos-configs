{ config
, lib
, ... }:

{
  services.radarr = {
    enable = true;
    user = "arr";
    group = config.services.rtorrent.group;
    openFirewall = true;
    settings = {
      update.mechanism = "builtIn";
      server = {
        port = 7878;
        bindaddress = "*";
      };
    };
  };

  systemd.services.radarr.serviceConfig.SupplementaryGroups = [ config.services.rtorrent.group ];

  services.nginx.virtualHosts."radarr.fuckk.lol" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = lib.mkProxy {
      ip = "192.168.100.1";
      port = config.services.radarr.settings.server.port;
    };
  };
}