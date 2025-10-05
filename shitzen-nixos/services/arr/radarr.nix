{ config, inputs, lib, pkgs, ... }:

let
  mkProxy = import ../../modules/mkproxy.nix;
in {
  services.radarr = {
    enable = true;
    group = config.services.rtorrent.group;
    openFirewall = true;
    settings = {
      update.mechanism = "builtIn";
      server = {
        port = 7878;
        bindaddress = "*";
      };
    };
  };

  systemd.services.radarr.serviceConfig.SupplementaryGroups = [ config.services.rtorrent.group ];

  services.nginx.virtualHosts."radarr.fuckk.lol" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = mkProxy {
      port = config.services.radarr.settings.server.port;
    };
  };
}