{ config
, ... }:

let
  mkProxy = import ../../../modules/mkproxy.nix;
in {
  services.readarr = {
    enable = true;
    user = "arr";
    group = config.services.rtorrent.group;
    openFirewall = true;
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
    locations."/" = mkProxy {
      port = config.services.readarr.settings.server.port;
    };
  };
}