{ config, inputs, lib, pkgs, ... }:

{
  imports = [
    nginx/fuckk_lol.nix
    nginx/furryporn_ca.nix
  ];

  services.nginx = {
    appendHttpConfig = ''
      # Add HSTS header with preloading to HTTPS requests
      map $scheme $hsts_header {
          https   "max-age=31536000; includeSubdomains; preload";
      }
      add_header Strict-Transport-Security $hsts_header;

      # Enable CSP
      #add_header Content-Security-Policy "script-src 'self'; object-src 'none'; base-uri 'none';" always;

      # Minimize information leaked to other domains
      add_header 'Referrer-Policy' 'origin-when-cross-origin';

      # Prevent injection of code in other mime types (XSS Attacks)
      add_header X-Content-Type-Options nosniff;
    '';

    enable = true;
    enableReload = true;

    proxyTimeout = "900s";

    recommendedBrotliSettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedZstdSettings = true;

    virtualHosts = {
      "fuckk.lol" = {
        enableACME = true;
        forceSSL = true;
        locations = {
          "/" = {
            alias = "/data/services/web/";
            index = "index.html";
          };
          "/private/" = {
            alias = "/data/private/";
            index = "index.htm";
            extraConfig = ''
              return 404;
            '';
          };
          "/private/anime/" = {
            alias = "/data/private/anime/";
            index = "index.htm";
            extraConfig = ''
              autoindex on;
              autoindex_exact_size off;
            '';
          };
          "/private/downloads/" = {
            alias = "/data/private/downloads/";
            index = "index.htm";
            extraConfig = ''
              autoindex on;
              autoindex_exact_size off;
            '';
          };
          "/private/images/" = {
            alias = "/data/private/images/";
            index = "index.htm";
            extraConfig = ''
              autoindex on;
              autoindex_exact_size off;
            '';
          };
        };
      };
    };
  };
}