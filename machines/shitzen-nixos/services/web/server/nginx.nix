{ config
, lib
, pkgs
, ... }:

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
    enable = true;
    enableReload = true;
    commonHttpConfig = ''
      # Proxy settings
      proxy_headers_hash_max_size 512;
      proxy_headers_hash_bucket_size 64;

      # Setup Real-IP
      real_ip_header CF-Connecting-IP;
      set_real_ip_from 173.245.48.0/20;
      set_real_ip_from 103.21.244.0/22;
      set_real_ip_from 103.22.200.0/22;
      set_real_ip_from 103.31.4.0/22;
      set_real_ip_from 141.101.64.0/18;
      set_real_ip_from 108.162.192.0/18;
      set_real_ip_from 190.93.240.0/20;
      set_real_ip_from 188.114.96.0/20;
      set_real_ip_from 197.234.240.0/22;
      set_real_ip_from 198.41.128.0/17;
      set_real_ip_from 162.158.0.0/15;
      set_real_ip_from 104.16.0.0/13;
      set_real_ip_from 104.24.0.0/14;
      set_real_ip_from 172.64.0.0/13;
      set_real_ip_from 131.0.72.0/22;
    '';

    recommendedBrotliSettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    experimentalZstdSettings = true;
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

  services.nginx.virtualHosts."monitoring.ajaxvpn.org" = {
    enableACME = true;
    forceSSL = true;
    locations = {
      "/grafana/" = lib.mkProxy {
        ip = "192.168.100.1";
        port = 3200;
      };
      "/prometheus/" = lib.mkProxy {
        ip = "192.168.100.1";
        port = 3201;
      };
    };
  };

  systemd.services.nginx.serviceConfig.SupplementaryGroups = [ config.services.rtorrent.group ];
}