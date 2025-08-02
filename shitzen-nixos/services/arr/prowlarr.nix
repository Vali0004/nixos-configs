{ config, inputs, lib, pkgs, ... }:

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

  services.nginx.virtualHosts."prowlarr.fuckk.lol" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:9696";
      proxyWebsockets = true;
    };
  };
}