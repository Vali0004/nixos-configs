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

      # Disable embedding as a frame
      add_header X-Frame-Options DENY;

      # Prevent injection of code in other mime types (XSS Attacks)
      add_header X-Content-Type-Options nosniff;
    '';
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    virtualHosts = {
      "fuckk.lol" = {
        enableACME = true;
        forceSSL = true;
        locations = {
          "/" = {
            alias = "/data/web/";
            index = "index.html";
          };
          "/private/anime" = {
            alias = "/data/private/anime";
            index = "index.htm";
            extraConfig = ''
              autoindex on;
              autoindex_exact_size off;
            '';
          };
          "/private/games" = {
            alias = "/data/private/games";
            index = "index.htm";
            extraConfig = ''
              autoindex on;
              autoindex_exact_size off;
            '';
          };
          "/private/movies" = {
            alias = "/data/private/movies";
            index = "index.htm";
            extraConfig = ''
              autoindex on;
              autoindex_exact_size off;
            '';
          };
          "/private/images" = {
            alias = "/data/private/images";
            index = "index.htm";
            extraConfig = ''
              autoindex on;
              autoindex_exact_size off;
            '';
          };
          "/private/nands/" = {
            alias = "/data/private/nands/";
            index = "index.htm";
            extraConfig = ''
              return 404;
            }
            location = "/private/nands/Clever Corona 16mb.zip" {
              alias "/data/private/nands/Clever Corona 16mb.zip";
            }
            location = "/private/nands/White R2D2 Corona 16mb.zip" {
              alias "/data/private/nands/White R2D2 Corona 16mb.zip";
            }
            location = "/private/nands/White Falcon Corona 16mb.zip" {
              alias "/data/private/nands/White Falcon Corona 16mb.zip";
            '';
          };
          "/private/secret/" = {
            alias = "/data/private/secret/";
            index = "index.htm";
            extraConfig = ''
              return 404;
            '';
          };
        };
      };
    };
  };
}