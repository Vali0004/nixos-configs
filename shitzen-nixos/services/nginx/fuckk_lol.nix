{ config, inputs, lib, pkgs, ... }:

let
  mkProxy = import ./mkproxy.nix;
in {
  services.nginx.virtualHosts = {
    # smtp
    "smtp.fuckk.lol" = {
      enableACME = true;
      forceSSL = true;
      locations."/".extraConfig = ''
        return 404;
      '';
    };
    # Unison
    "unison.fuckk.lol" = {
      enableACME = true;
      forceSSL = true;
      locations."/".extraConfig = ''
        return 404;
      '';
    };
    # Dockge
    "dockge.fuckk.lol" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = mkProxy {
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
    # Sonarr
    "sonarr.fuckk.lol" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8989";
        proxyWebsockets = true;
      };
    };
    # Proxmox
    "proxmox.fuckk.lol" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8006";
        proxyWebsockets = true;
      };
    };
    # Cors anywhere
    "r34.fuckk.lol" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = mkProxy {
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
}