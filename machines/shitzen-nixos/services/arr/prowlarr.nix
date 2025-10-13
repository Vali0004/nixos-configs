{ config, inputs, lib, pkgs, ... }:

let
  mkProxy = import ../../modules/mkproxy.nix;
in {
  services.prowlarr = {
    enable = true;
    openFirewall = true;
    package = pkgs.callPackage ./prowlarr-package {};
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
    locations."/" = mkProxy {
      port = config.services.prowlarr.settings.server.port;
    };
  };
}