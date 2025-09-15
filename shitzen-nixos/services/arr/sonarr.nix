{ config, inputs, lib, pkgs, ... }:

{
  services.sonarr = {
    enable = true;
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
    locations."/" = {
      proxyPass = "http://192.168.100.1:8989";
      proxyWebsockets = true;
    };
  };
}