{ config, inputs, lib, pkgs, ... }:

let
  mkProxy = import ./mkproxy.nix;
in {
  services.nginx.virtualHosts = {
    "valis.furryporn.ca" = {
      enableACME = true;
      forceSSL = true;
      locations = {
        "/" = {
          alias = "/data/valisfurryporn/";
          index = "index.html";
        };
      };
    };
    # Jellyfin
    "watch.furryporn.ca" = {
      enableACME = true;
      forceSSL = true;
      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:8096";
          proxyWebsockets = true;
        };
      };
    };
    # Unison ptero
    "unison.fuckk.lol" = {
      enableACME = true;
      forceSSL = true;
      locations = {
        "/" = {
          alias = "/data/private/";
          index = "index.htm";
          extraConfig = ''
            return 404;
          '';
        };
      };
    };
  };
}