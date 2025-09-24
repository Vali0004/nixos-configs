{ config, inputs, lib, pkgs, ... }:

let
  mkProxy = import ./../../modules/mkproxy.nix;
in {
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
    locations."/" = mkProxy {
      port = config.services.sonarr.settings.server.port;
    };
  };
}