{ config
, lib
, ... }:

{
  services.prowlarr = {
    enable = true;
    openFirewall = true;
    settings = {
      update.mechanism = "builtIn";
      server = {
        port = 9696;
        bindaddress = "*";
      };
    };
  };

  systemd.services.prowlarr.serviceConfig.SupplementaryGroups = [ config.services.rtorrent.group ];

  services.nginx.virtualHosts."prowlarr.kursu.dev" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = lib.mkProxy {
      ip = "192.168.100.1";
      port = config.services.prowlarr.settings.server.port;
    };
  };
}