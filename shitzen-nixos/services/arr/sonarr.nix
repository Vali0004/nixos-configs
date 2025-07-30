{ config, inputs, lib, pkgs, ... }:

{
  services.sonarr = {
    dataDir = "/data/services/sonarr/data";
    enable = true;
    openFirewall = true;
  };

  systemd.services.sonarr.serviceConfig.SupplementaryGroups = [ config.services.rtorrent.group ];

  services.nginx.virtualHosts."sonarr.fuckk.lol" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:8989";
      proxyWebsockets = true;
    };
  };
}