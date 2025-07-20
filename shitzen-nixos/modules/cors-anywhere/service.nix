{ config, pkgs, ... }:

let
  cors_anywhere = pkgs.callPackage ./package.nix {};
  mkProxy = import ./../../services/nginx/mkproxy.nix;
in {
  environment.systemPackages = with pkgs; [
    nodejs_20
    cors_anywhere
  ];
  systemd.services.cors-anywhere = {
    enable = true;
    description = "Proxy to strip CORS from a request";
    unitConfig = {
      Type = "simple";
    };
    serviceConfig = {
      Environment = [
        "PORT=8099"
        "CORSANYWHERE_WHITELISTED_TARGETS=api-cdn.rule34.xxx,api.rule34.xxx,rule34.xxx"
      ];
      ExecStart = "${pkgs.nodejs_20}/bin/node ${cors_anywhere}/lib/node_modules/cors-anywhere/server.js";
    };
    wantedBy = [ "multi-user.target" ];
  };

  services.nginx.virtualHosts."r34.fuckk.lol" = {
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
}