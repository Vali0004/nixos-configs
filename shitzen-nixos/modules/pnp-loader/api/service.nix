{ config, pkgs, ... }:

let
  pnp-api = pkgs.callPackage ./package.nix {};
  mkProxy = import ./../../mkproxy.nix;
in {
  systemd.services.pnp-api = {
    enable = true;
    description = "PnP-API";
    serviceConfig = {
      ExecStart = "${pkgs.nodejs_20}/bin/node ${pnp-api}/lib/node_modules/pnp-api/server.js";
      EnvironmentFile = config.age.secrets.pnp-api.path;
      Restart = "always";
    };
    wantedBy = [ "multi-user.target" ];
  };

  services.nginx.virtualHosts."api.pnploader.ru" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = mkProxy {
      ip = "192.168.100.1";
      port = 3201;
      webSockets = true;
    };
  };
}