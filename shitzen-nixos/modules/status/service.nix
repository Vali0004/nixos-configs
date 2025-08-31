{ config, pkgs, ... }:

let
  mkProxy = import ./../mkproxy.nix;
  status = pkgs.callPackage ./package.nix {};
in {
  environment.systemPackages = [
    pkgs.nodejs_20
    status
  ];

  systemd.services.fuckk-lol-status = {
    enable = true;
    description = "Proxy to strip CORS from a request";
    serviceConfig = {
      Environment = [
        "PORT=3004"
      ];
      ExecStart = "${pkgs.nodejs_20}/bin/node ${status}/lib/node_modules/fuckk-lol-status/server.js";
    };
    wantedBy = [ "multi-user.target" ];
  };

  services.nginx.virtualHosts."status.fuckk.lol" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = mkProxy {
      port = 3004;
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