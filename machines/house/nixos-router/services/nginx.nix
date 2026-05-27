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

  acme.enable = true;

  services.nginx.virtualHosts = {
    "router.localnet" = {
      forceSSL = false;
      locations."/" = lib.mkProxy {
        ip = "127.0.0.1";
        port = 4390;
      };
    };
    "flood.localnet" = {
      forceSSL = false;
      locations."/" = lib.mkProxy {
        ip = "shitzen-nixos";
        port = 3702;
      };
    };
    "flood-private.localnet" = {
      forceSSL = false;
      locations."/" = lib.mkProxy {
        ip = "shitzen-nixos";
        port = 3703;
      };
    };
    "git.localnet" = {
      forceSSL = false;
      locations."/" = lib.mkProxy {
        ip = "shitzen-nixos";
        port = 3900;
      };
    };
    "hass.localnet" = {
      forceSSL = false;
      locations."/" = lib.mkProxy {
        ip = "home-assistant";
        port = 8123;
      };
    };
    "internal.lab004.dev" = {
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
        "/private/downloads/" = {
          alias = "/mnt/data/private/downloads/";
          index = "index.htm";
          extraConfig = ''
            autoindex on;
            autoindex_exact_size off;
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
          alias = "/mnt/data/private/Media/Movies/";
          index = "index.htm";
          extraConfig = ''
            autoindex on;
            autoindex_exact_size off;
          '';
        };
        "/private/incoming/" = {
          alias = "/mnt/data/incoming/";
          index = "index.htm";
          extraConfig = ''
            autoindex on;
            autoindex_exact_size off;
          '';
        };
        "/people/cleverca22/" = {
          alias = "/mnt/data/people/cleverca22/";
          index = "index.htm";
          extraConfig = ''
            autoindex on;
            autoindex_exact_size off;
          '';
        };
        "/people/unison/" = {
          alias = "/mnt/data/people/unison/";
          index = "index.htm";
          extraConfig = ''
            autoindex on;
            autoindex_exact_size off;
          '';
        };
      };
    };
    "hass.lab004.dev" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = lib.mkProxy {
        ip = "home-assistant";
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
    "lidarr.localnet" = {
      forceSSL = false;
      locations."/" = lib.mkProxy {
        ip = "shitzen-nixos";
        port = 8686;
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
        "/grafana/" = lib.mkProxy {
          ip = "shitzen-nixos";
          port = 3003;
        };
      };
    };
    "manga.localnet" = {
      forceSSL = false;
      locations."/" = lib.mkProxy {
        ip = "shitzen-nixos";
        port = 8788;
      };
    };
    "prowlarr.localnet" = {
      forceSSL = false;
      locations."/" = lib.mkProxy {
        ip = "shitzen-nixos";
        port = 9696;
      };
    };
    "radarr.localnet" = {
      forceSSL = false;
      locations."/" = lib.mkProxy {
        ip = "shitzen-nixos";
        port = 7878;
      };
    };
    "readarr.localnet" = {
      forceSSL = false;
      locations."/" = lib.mkProxy {
        ip = "shitzen-nixos";
        port = 8787;
      };
    };
    "sonarr.localnet" = {
      forceSSL = false;
      locations."/" = lib.mkProxy {
        ip = "shitzen-nixos";
        port = 8989;
      };
    };
    "vaultwarden.localnet" = {
      forceSSL = false;
      locations."/" = lib.mkProxy {
        ip = "shitzen-nixos";
        port = 8222;
      };
    };
    "zigbee2mqtt.localnet" = {
      forceSSL = false;
      locations."/" = lib.mkProxy {
        ip = "home-assistant";
        port = 8099;
      };
    };
  };
}