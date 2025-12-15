{ config
, lib
, ... }:

{
  services.sonarr = {
    enable = true;
    user = "arr";
    group = config.services.rtorrent.group;
    openFirewall = true;
    settings = {
      update.mechanism = "builtIn";
      server = {
        port = 8989;
        bindaddress = "*";
      };
    };
  };

  systemd.services.radarr.serviceConfig.SupplementaryGroups = [ config.services.rtorrent.group ];

  services.nginx.virtualHosts."sonarr.fuckk.lol" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = lib.mkProxy {
      ip = "192.168.100.1";
      port = config.services.sonarr.settings.server.port;
    };
  };
}