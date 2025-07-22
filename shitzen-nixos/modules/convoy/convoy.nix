{ config, pkgs, lib, ... }:

let
  phpPkg = pkgs.php82.buildEnv {
    extensions = ({ enabled, all }: enabled ++ (with all; [
      gmp
      opcache
      pcntl
      pdo_mysql
      redis
      sodium
    ]));
  };

  sqlPkg = pkgs.mariadb;

  convoyPanelSrc = ./convoy-panel-offline.tar.gz;

  convoyEnvFile = config.age.secrets.convoy.path;
in {
  services.phpfpm.pools.convoy = {
    user = "nginx";
    group = "nginx";
    phpPackage = phpPkg;
    phpOptions = ''
      post_max_size = 100M
      upload_max_filesize = 100M
      open_basedir = /var/lib/convoy-panel:/tmp:/proc:/dev/urandom
    '';
    settings = {
      "listen.owner" = "nginx";
      "listen.group" = "nginx";
      "pm" = "dynamic";
      "pm.max_children" = 32;
      "pm.start_servers" = 2;
      "pm.min_spare_servers" = 2;
      "pm.max_spare_servers" = 4;
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/convoy-panel/storage - nginx nginx 0755 - -"
    "d /var/lib/convoy-panel/storage/framework - nginx nginx 0755 - -"
    "d /var/lib/convoy-panel/storage/framework/views - nginx nginx 0755 - -"
    "d /var/lib/convoy-panel/bootstrap/cache - nginx nginx 0755 - -"
    "d /run/phpfpm 0755 root root - -"
  ];

  services.nginx.virtualHosts."convoy.fuckk.lol" = {
    enableACME = true;
    forceSSL = true;
    root = "/var/lib/convoy-panel/public";
    extraConfig = ''
      index index.php;
      client_max_body_size 100m;
      client_body_timeout 120s;
      sendfile off;
    '';
    locations."/".extraConfig = ''
      try_files $uri $uri/ /index.php?$query_string;
    '';
    locations."~ \\.php$".extraConfig = ''
      fastcgi_split_path_info ^(.+\.php)(/.+)$;
      fastcgi_pass unix:/run/phpfpm/convoy.sock;
      fastcgi_index index.php;
      fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
      fastcgi_param HTTP_PROXY "";
      include ${pkgs.nginx}/conf/fastcgi_params;
      include ${pkgs.nginx}/conf/fastcgi.conf;
    '';
    locations."~ /\\.ht".extraConfig = "deny all;";
  };

  systemd.services.convoy-panel-install = {
    description = "Install Convoy panel to writable location";
    wantedBy = [ "multi-user.target" ];
    before = [ "phpfpm-convoy.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "extract-convoy" ''
        set -eux
        mkdir -p /var/lib/convoy-panel
        ${pkgs.gzip}/bin/gzip -dc ${convoyPanelSrc} | ${pkgs.gnutar}/bin/tar -x -C /var/lib/convoy-panel --strip-components=1
        cp ${convoyEnvFile} /var/lib/convoy-panel/.env
        mkdir -p /var/lib/convoy-panel/storage
        mkdir -p /var/lib/convoy-panel/bootstrap/cache
        chown -R nginx:nginx /var/lib/convoy-panel
      '';
      RemainAfterExit = true;
    };
  };

  systemd.services.convoy-horizon = {
    description = "Laravel Horizon";
    wantedBy = [ "multi-user.target" ];
    after = [ "convoy-panel-install.service" "redis.convoy.service" ];
    unitConfig = {
      ConditionPathExists = "/var/lib/convoy-panel/.env";
    };
    serviceConfig = {
      User = "nginx";
      Group = "nginx";
      WorkingDirectory = "/var/lib/convoy-panel";
      ExecStart = "${phpPkg}/bin/php artisan horizon";
      Restart = "always";
      RestartSec = "5s";
    };
  };

  systemd.services.convoy-queue-worker = {
    description = "Laravel Queue Worker";
    wantedBy = [ "multi-user.target" ];
    after = [ "convoy-panel-install.service" "redis.convoy.service" ];
    unitConfig = {
      ConditionPathExists = "/var/lib/convoy-panel/.env";
    };
    serviceConfig = {
      User = "nginx";
      Group = "nginx";
      WorkingDirectory = "/var/lib/convoy-panel";
      ExecStart = "${phpPkg}/bin/php artisan queue:work --verbose --no-interaction --queue=high,standard,low --sleep=3 --tries=3";
      Restart = "always";
      RestartSec = "5s";
    };
  };
}