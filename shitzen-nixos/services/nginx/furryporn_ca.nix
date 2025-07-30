{ config, inputs, lib, pkgs, ... }:

let
  mkProxy = import ./../../modules/mkproxy.nix;
in {
  services.nginx.virtualHosts = {
    "valis.furryporn.ca" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        alias = "/data/services/valisfurryporn/";
        index = "index.html";
      };
    };
  };
}