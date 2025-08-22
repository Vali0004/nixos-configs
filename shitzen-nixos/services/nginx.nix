{ config, inputs, lib, pkgs, ... }:

{
  services.nginx = {
    enable = true;
    enableReload = true;

    proxyTimeout = "900s";

    recommendedBrotliSettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedZstdSettings = true;
  };

  services.nginx.virtualHosts."fuckk.lol" = {
    enableACME = true;
    forceSSL = true;
    locations = {
      "/" = {
        alias = "/data/services/web/";
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
    locations."/" = {
      alias = "/data/services/valisfurryporn/";
      index = "index.html";
    };
  };

  systemd.services.nginx.serviceConfig.SupplementaryGroups = [ config.services.rtorrent.group ];
}