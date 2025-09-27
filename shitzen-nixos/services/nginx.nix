{ config, inputs, lib, pkgs, ... }:

let
  compressMimeTypes = [
    "application/atom+xml"
    "application/geo+json"
    "application/javascript" # Deprecated by IETF RFC 9239, but still widely used
    "application/json"
    "application/ld+json"
    "application/manifest+json"
    "application/rdf+xml"
    "application/vnd.ms-fontobject"
    "application/wasm"
    "application/x-rss+xml"
    "application/x-web-app-manifest+json"
    "application/xhtml+xml"
    "application/xliff+xml"
    "application/xml"
    "font/collection"
    "font/otf"
    "font/ttf"
    "image/bmp"
    "image/svg+xml"
    "image/vnd.microsoft.icon"
    "text/cache-manifest"
    "text/calendar"
    "text/css"
    "text/csv"
    "text/javascript"
    "text/markdown"
    "text/plain"
    "text/vcard"
    "text/vnd.rim.location.xloc"
    "text/vtt"
    "text/x-component"
    "text/xml"
  ];
in {
  services.nginx = {
    additionalModules = [ pkgs.nginxModules.brotli ];
    commonHttpConfig = ''
      # Optimisation
      sendfile on;
      tcp_nopush on;
      tcp_nodelay on;
      keepalive_timeout 65;

      # Keep in sync with https://ssl-config.mozilla.org/#server=nginx&config=intermediate
      ssl_ecdh_curve X25519:prime256v1:secp384r1;
      ssl_session_timeout 1d;
      ssl_session_cache shared:SSL:10m;
      # Breaks forward secrecy: https://github.com/mozilla/server-side-tls/issues/135
      ssl_session_tickets off;
      # We don't enable insecure ciphers by default, so this allows
      # clients to pick the most performant, per https://github.com/mozilla/server-side-tls/issues/260
      ssl_prefer_server_ciphers off;

      # Enable Brotli
      brotli on;
      brotli_static on;
      brotli_comp_level 5;
      brotli_window 512k;
      brotli_min_length 256;
      brotli_types ${lib.concatStringsSep " " compressMimeTypes};

      # Proxy settings
      proxy_redirect off;
      proxy_connect_timeout 120s;
      proxy_send_timeout 120s;
      proxy_read_timeout 120s;
      proxy_http_version 1.1;
      map $http_upgrade $connection_upgrade {
          default upgrade;
          ${"''"}      "";
      }
    '';
    enable = true;
    enableReload = true;

    # We handle these ourselves.
    recommendedBrotliSettings = lib.mkForce false;
    recommendedGzipSettings = lib.mkForce false;
    recommendedOptimisation = lib.mkForce false;
    recommendedProxySettings = lib.mkForce false;
    recommendedTlsSettings = lib.mkForce false;
    experimentalZstdSettings = lib.mkForce false;
  };

  services.nginx.virtualHosts."fuckk.lol" = {
    enableACME = true;
    forceSSL = true;
    root = "/data/services/web/fuckk-lol/";
    locations = {
      "/" = {
        index = "index.html";
      };
      "/repo/" = {
        alias = "/data/services/web/repo/";
        index = "index.htm";
        extraConfig = ''
          autoindex on;
          autoindex_exact_size off;
        '';
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
      "/private/movies/" = {
        alias = "/data/private/movies/";
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

  services.nginx.virtualHosts."valis.furryporn.ca" = {
    enableACME = true;
    forceSSL = true;
    root = "/data/services/web/valisfurryporn/";
    locations."/" = {
      index = "index.html";
    };
  };

  services.nginx.virtualHosts."xenonemu.dev" = {
    enableACME = true;
    forceSSL = true;
    root = "/data/services/web/xenonemu/";
    locations."/" = {
      index = "index.html";
    };
  };

  systemd.services.nginx.serviceConfig.SupplementaryGroups = [ config.services.rtorrent.group ];
}