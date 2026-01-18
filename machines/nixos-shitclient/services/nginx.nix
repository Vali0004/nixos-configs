{ config
, lib
, ... }:

{
  services.nginx = {
    enable = true;
    enableReload = true;
    recommendedBrotliSettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    experimentalZstdSettings = true;
  };

  services.nginx.virtualHosts = {
    "hass.localnet" = {
      forceSSL = false;
      locations."/" = lib.mkProxy {
        ip = "nixos-hass";
        port = 8123;
      };
    };
    "internal.kursu.dev" = {
      enableACME = true;
      forceSSL = true;
      locations = {
        "/private/" = {
          alias = "/mnt/data/private/Media/";
          index = "index.htm";
          extraConfig = ''
            return 404;
          '';
        };
        "/private/anime/" = {
          alias = "/mnt/data/private/Media/Anime/";
          index = "index.htm";
          extraConfig = ''
            autoindex on;
            autoindex_exact_size off;
          '';
        };
        "/private/movies/" = {
          alias = "/mnt/data/private/Media/Movies";
          index = "index.htm";
          extraConfig = ''
            autoindex on;
            autoindex_exact_size off;
          '';
        };
      };
    };
    "hass.kursu.dev" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = lib.mkProxy {
        ip = "nixos-hass";
        port = 8123;
      };
    };
    "jellyfin.localnet" = {
      forceSSL = false;
      locations."/" = {
        proxyPass = "http://10.0.0.4:8096";
        proxyWebsockets = true;
      };
    };
    "rtorrent.localnet" = {
      forceSSL = false;
      locations."/" = {
        proxyPass = "http://10.0.0.4:6110";
        proxyWebsockets = true;
      };
    };
    "kvm.localnet" = {
      forceSSL = false;
      locations."/" = {
        proxyPass = "http://10.0.0.5";
        proxyWebsockets = true;
      };
    };
    "monitoring.localnet" = {
      forceSSL = false;
      locations = {
        "/" = {
          return = "302 /grafana/";
        };
        "/prometheus/" = lib.mkProxy {
          ip = "shitzen-nixos";
          port = 3400;
        };
        "/grafana/" = {
          proxyPass = "http://10.0.0.4:3003";
          proxyWebsockets = true;
        };
      };
    };
    "zigbee2mqtt.localnet" = {
      forceSSL = false;
      locations."/" = lib.mkProxy {
        ip = "nixos-hass";
        port = 8099;
      };
    };
  };
}