{ config, inputs, lib, pkgs, ... }:

let
  mkProxy = import ./../../modules/mkproxy.nix;
in {
  services.nginx.virtualHosts."dockge.fuckk.lol" = {
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
}