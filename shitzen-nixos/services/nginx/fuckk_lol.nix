{ config, inputs, lib, pkgs, ... }:

let
  mkProxy = import ./mkproxy.nix;
in {
  services.nginx.virtualHosts = {
    # Webmail (Roundcube)
    "webmail.fuckk.lol" = {
      enableACME = true;
      forceSSL = true;
      root = "${pkgs.roundcube}";
      locations."/" = {
        index = "index.php";
        priority = 1100;
      };
      locations."~ ^/(SQL|bin|config|logs|temp|vendor)/" = {
        priority = 3110;
        extraConfig = ''
          return 404;
        '';
      };
      locations."~ ^/(CHANGELOG.md|INSTALL|LICENSE|README.md|SECURITY.md|UPGRADING|composer.json|composer.lock)" = {
        priority = 3120;
        extraConfig = ''
          return 404;
        '';
      };
      locations."~* \\.php(/|$)" = {
        priority = 3130;
        extraConfig = ''
          fastcgi_pass unix:${config.services.phpfpm.pools.roundcube.socket};
          fastcgi_param PATH_INFO $fastcgi_path_info;
          fastcgi_split_path_info ^(.+\.php)(/.+)$;
          include ${config.services.nginx.package}/conf/fastcgi.conf;
        '';
      };
    };
    # smtp
    "smtp.fuckk.lol" = {
      enableACME = true;
      forceSSL = true;
      locations."/".extraConfig = ''
        return 404;
      '';
    };
    # Unison
    "unison.fuckk.lol" = {
      enableACME = true;
      forceSSL = true;
      locations."/".extraConfig = ''
        return 404;
      '';
    };
    # Dockge
    "dockge.fuckk.lol" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = mkProxy {
        port = 5001;
        webSockets = true;
        config = ''
          proxy_ssl_server_name on;
          proxy_ssl_name $proxy_host;
          proxy_cache_bypass $http_upgrade;
          proxy_set_header X-Requested-With XMLHttpRequest;
        '';
      };
    };
    # Sonarr
    "sonarr.fuckk.lol" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8989";
        proxyWebsockets = true;
      };
    };
    # Prowlarr
    "prowlarr.fuckk.lol" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:9696";
        proxyWebsockets = true;
      };
    };
    # Proxmox
    "proxmox.fuckk.lol" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "https://127.0.0.1:8006";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_ssl_verify off;
        '';
      };
    };
    # Cors anywhere
    "r34.fuckk.lol" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = mkProxy {
        port = 8099;
        webSockets = true;
        config = ''
          proxy_ssl_server_name on;
          proxy_ssl_name $proxy_host;
          proxy_cache_bypass $http_upgrade;
          proxy_set_header X-Requested-With XMLHttpRequest;
        '';
      };
    };
  };
}