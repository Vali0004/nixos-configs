{ config, inputs, lib, pkgs, ... }:

{
  services.jellyfin = {
    configDir = "/data/services/jellyfin/config";
    dataDir = "/data/services/jellyfin/data";
    logDir = "/data/services/jellyfin/log";
    enable = true;
    openFirewall = true;
    user = "vali";
  };

  services.nginx.virtualHosts."ohh.fuckk.lol" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:8096";
      proxyWebsockets = true;
    };
  };
}