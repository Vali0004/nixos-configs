{ config, inputs, lib, pkgs, ... }:

let
  mkProxy = import ./mkproxy.nix;
in {
  services.nginx.virtualHosts = {
    # Unison
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

    # Zipline
    "holy.fuckk.lol" = {
      enableACME = true;
      forceSSL = true;
      locations = {
        "/" = mkProxy {
          port = 3000;
          webSockets = true;
        };
      };
    };

    # Cors anywhere
    "r34.fuckk.lol" = {
      enableACME = true;
      forceSSL = true;
      locations = {
        "/" = mkProxy {
          port = 8099;
          webSockets = true;
          config = ''
            proxy_ssl_server_name on;
            proxy_ssl_name $proxy_host;
            proxy_cache_bypass $http_upgrade;
            proxy_set_header X-Requested-With XMLHttpRequest;
          '';
        };
      };
    };
  };
}