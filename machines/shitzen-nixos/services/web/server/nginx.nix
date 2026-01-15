{ config
, lib
, pkgs
, ... }:

{
  services.nginx = {
    enable = true;
    enableReload = true;
    commonHttpConfig = ''
      # Proxy settings
      proxy_headers_hash_max_size 512;
      proxy_headers_hash_bucket_size 64;

      # Setup Real-IP
      real_ip_header CF-Connecting-IP;
      real_ip_recursive on;
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
      "/.well-known/discord" = {
        extraConfig = ''
          default_type text/plain;
          return 200 "dh=bf1a6bc8c4e60bb02a061066aab4dc9366273a03";
        '';
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

  services.nginx.virtualHosts."kursu.dev" = {
    enableACME = true;
    forceSSL = true;
    root = "/data/services/web/fuckk-lol/";
    locations = {
      "/" = {
        index = "index.html";
      };
      "/.well-known/discord" = {
        extraConfig = ''
          default_type text/plain;
          return 200 "dh=a3c0df477f4d412f5affcafe7f0b5afa578acf37";
        '';
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

  services.nginx.virtualHosts."furryfemboy.ca" = {
    enableACME = true;
    forceSSL = true;
    root = "/data/services/web/furryfemboy/";
    locations = {
      "/" = {
        index = "index.html";
      };
      "/.well-known/discord" = {
        extraConfig = ''
          default_type text/plain;
          return 200 "dh=aad0196d7331cca572842dac1711a1ae374bc50f";
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