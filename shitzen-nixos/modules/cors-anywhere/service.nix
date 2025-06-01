{ config, pkgs, ... }:

let
  cors_anywhere = pkgs.callPackage ./package.nix {};
in {
  # TODO: Setup a auto-deploy script
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
      Environment = "PORT=8099";
      ExecStart = "${pkgs.nodejs_20}/bin/node ${cors_anywhere}/lib/node_modules/cors-anywhere/server.js";
    };
    wantedBy = [ "multi-user.target" ];
  };
}