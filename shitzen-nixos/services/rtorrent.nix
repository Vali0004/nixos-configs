{ config, pkgs, lib, ... }:

let
  peer-port = 50000;
  web-port = 3002;
in {
  services.rtorrent = {
    downloadDir = "/data/services/downloads/rtorrent";
    enable = true;
    port = peer-port;
    openFirewall = true;
  };

  services.flood = {
    enable = true;
    port = web-port;
    openFirewall = true;
    extraArgs = ["--rtsocket=${config.services.rtorrent.rpcSocket}"];
  };

  services.nginx.virtualHosts."flood.fuckk.lol" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:3002";
      proxyWebsockets = true;
    };
  };

  systemd.services.flood.serviceConfig.SupplementaryGroups = [ config.services.rtorrent.group ];
}