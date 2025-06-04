{ config, inputs, lib, pkgs, ... }:

let
  mkProxy = import ./mkproxy.nix;
in {
  services.nginx.virtualHosts = {
    # smtp
    "smtp.fuckk.lol" = {
      enableACME = true;
      forceSSL = true;
      locations = {
        "/" = {
          extraConfig = ''
            return 404;
          '';
        };
      };
    };
    # Unison
    "unison.fuckk.lol" = {
      enableACME = true;
      forceSSL = true;
      locations = {
        "/" = {
          extraConfig = ''
            return 404;
          '';
        };
      };
    };
    # Dockge
    "dockge.fuckk.lol" = {
      enableACME = true;
      forceSSL = true;
      locations = {
        "/" = mkProxy {
          port = 5001;
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