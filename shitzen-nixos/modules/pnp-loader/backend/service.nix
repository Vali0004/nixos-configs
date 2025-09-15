{ config, pkgs, ... }:

let
  pnp-loader = pkgs.callPackage ./package.nix {};
  mkProxy = import ./../../mkproxy.nix;
in {
  systemd.services.pnp-loader = {
    enable = true;
    description = "PnP-Loader";
    serviceConfig = {
      ExecStart = "${pkgs.nodejs_20}/bin/node ${pnp-loader}/lib/node_modules/pnp-loader/server.js";
      EnvironmentFile = config.age.secrets.pnp-loader.path;
      Restart = "always";
    };
    wantedBy = [ "multi-user.target" ];
  };

  services.nginx.virtualHosts."s1-luna2.pnploader.ru" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = mkProxy {
      ip = "192.168.100.1";
      port = 3200;
      webSockets = true;
      config = ''
        proxy_ssl_server_name on;
        proxy_ssl_name $proxy_host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Requested-With XMLHttpRequest;
      '';
    };
  };

  services.nginx.virtualHosts."s1-luna.pnploader.ru" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = mkProxy {
      ip = "192.168.100.1";
      port = 3200;
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