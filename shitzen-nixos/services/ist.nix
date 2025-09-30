{ config, lib, pkgs, ... }:

let
  dataDir = "/data/services/web/ist/";
in {
  services.phpfpm.pools.ist = {
    user = "ist";
    settings = {
      "listen.owner" = config.services.nginx.user;
      "pm" = "dynamic";
      "pm.max_children" = 32;
      "pm.max_requests" = 500;
      "pm.start_servers" = 2;
      "pm.min_spare_servers" = 2;
      "pm.max_spare_servers" = 5;
      "php_admin_value[error_log]" = "stderr";
      "php_admin_flag[log_errors]" = true;
      "catch_workers_output" = true;
    };
    phpEnv."PATH" = lib.makeBinPath [ pkgs.php ];
  };

  services.nginx.virtualHosts."insanitysecurityteam.ru" = {
    enableACME = true;
    forceSSL = true;
    root = dataDir;
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
        fastcgi_pass unix:${config.services.phpfpm.pools.ist.socket};
        fastcgi_param PATH_INFO $fastcgi_path_info;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        include ${config.services.nginx.package}/conf/fastcgi.conf;
      '';
    };
  };

  users.users.ist = {
    isSystemUser = true;
    home = dataDir;
    group = "nginx";
  };

  users.groups.ist = {};
}