{ config, inputs, lib, pkgs, ... }:

{
  services.readarr = {
    enable = true;
    group = config.services.rtorrent.group;
    openFirewall = true;
    #package = pkgs.callPackage ./readarr-package {};
    settings = {
      update.mechanism = "builtIn";
      server = {
        port = 8787;
        bindaddress = "*";
      };
    };
  };

  systemd.services.readarr.serviceConfig.SupplementaryGroups = [ config.services.rtorrent.group ];

  services.nginx.virtualHosts."readarr.fuckk.lol" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://192.168.100.1:8787";
      proxyWebsockets = true;
    };
  };
}