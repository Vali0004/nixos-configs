{ config, pkgs, ... }:

let
  pnp-loader = pkgs.callPackage ./package.nix {};
in {
  systemd.services.pnp-loader = {
    enable = true;
    description = "PnP-Loader";
    serviceConfig = {
      ExecStart = "${pkgs.nodejs_20}/bin/node ${pnp-loader}/lib/node_modules/pnp-loader/server.js";
    };
    wantedBy = [ "multi-user.target" ];
  };

  services.nginx.virtualHosts."s1-luna.pnploader.ru" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:3200";
      proxyWebsockets = true;
    };
  };
}