{ config, inputs, lib, pkgs, ... }:

{
  services.radarr = {
    dataDir = "/data/services/radarr/data";
    enable = true;
    openFirewall = true;
  };

  systemd.services.radarr.serviceConfig.SupplementaryGroups = [ config.services.rtorrent.group ];

  services.nginx.virtualHosts."radarr.fuckk.lol" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:7878";
      proxyWebsockets = true;
    };
  };
}