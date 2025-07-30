{ config, inputs, lib, pkgs, ... }:

{
  services.prowlarr = {
    dataDir = "/data/services/prowlarr/data";
    enable = true;
    openFirewall = true;
  };

  systemd.services.prowlarr.serviceConfig.SupplementaryGroups = [ config.services.rtorrent.group ];

  services.nginx.virtualHosts."prowlarr.fuckk.lol" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:9696";
      proxyWebsockets = true;
    };
  };
}