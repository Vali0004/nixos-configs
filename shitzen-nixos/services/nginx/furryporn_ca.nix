{ config, inputs, lib, pkgs, ... }:

let
  mkProxy = import ./mkproxy.nix;
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
    # Jellyfin
    "watch.furryporn.ca" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8096";
        proxyWebsockets = true;
        extraConfig = ''
          add_header X-Auth-Request-User $http_x_auth_request_user;
          add_header X-Auth-Request-Email $http_x_auth_request_email;
          add_header Strict-Transport-Security $hsts_header;
          add_header Referrer-Policy origin-when-cross-origin;
          add_header X-Frame-Options DENY;
          add_header X-Content-Type-Options nosniff;
        '';
      };
    };
  };
}