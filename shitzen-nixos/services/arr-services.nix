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

  services.sonarr = {
    dataDir = "/data/services/sonarr/data";
    enable = true;
    group = "users";
    openFirewall = true;
    user = "vali";
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

  services.radarr = {
    dataDir = "/data/services/radarr/data";
    enable = true;
    group = "users";
    openFirewall = true;
    user = "vali";
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