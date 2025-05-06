{ config, inputs, lib, pkgs, ... }:

{
  services.nginx.virtualHosts = {
    "valis.furryporn.ca" = {
      enableACME = true;
      forceSSL = true;
      locations = {
        "/" = {
          alias = "/data/valisfurryporn/";
          index = "index.html";
        };
      };
    };
    "unison.fuckk.lol" = {
      enableACME = true;
      forceSSL = true;
      locations = {
        "/" = {
          alias = "/data/private/";
          index = "index.htm";
          extraConfig = ''
            return 404;
          '';
        };
      };
    };
  };
}