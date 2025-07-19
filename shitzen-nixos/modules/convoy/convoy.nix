{ config, pkgs, lib, ... }:

let
  phpPkg = pkgs.php82.buildEnv {
    extensions = ({ enabled, all }: enabled ++ (with all; [ redis ]));
  };

  sqlPkg = pkgs.mariadb;

  convoyPanelSrc = ./convoy-panel-offline.tar.gz;

  dbPassword = "dummypassword";

  createDefaultUser = false;
  defaultUserEmail = "vali@fuckk.lol";
  defaultUserPassword = "dummypassword";

  convoyEnvFile = pkgs.writeText "convoy.env" ''
    APP_NAME=Convoy
    APP_ENV=local
    APP_KEY=base64:KOE84mCJuY35SyW43jXLqH0vwlixA0JUeAV15it9QiU=
    APP_DEBUG=true
    APP_URL=https://fuckk.lol

    LOG_CHANNEL=stack
    LOG_LEVEL=debug

    DB_CONNECTION=mysql
    DB_HOST=127.0.0.1
    DB_PORT=3306
    DB_DATABASE=convoy
    DB_USERNAME=convoy
    DB_PASSWORD=${dbPassword}

    CACHE_DRIVER=redis
    QUEUE_CONNECTION=redis
    SESSION_DRIVER=redis
    SESSION_LIFETIME=525600

    REDIS_HOST=127.0.0.1
    REDIS_PORT=6380

    MAIL_MAILER=smtp
    MAIL_HOST=dovecot
    MAIL_PORT=465
    MAIL_FROM_ADDRESS="admin@fuckk.lol"
    MAIL_FROM_NAME="Convoy"

    PHP_XDEBUG=false
    PHP_XDEBUG_MODE='debug'
  '';
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

  systemd.services.convoy-db-setup = {
    description = "Ensure Convoy MySQL database and user exist";
    wantedBy = [ "multi-user.target" ];
    after = [ "mysql.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "create-convoy-db" ''
        set -eux
        ${sqlPkg}/bin/mysql -u root --protocol=socket <<'EOF'
          CREATE DATABASE IF NOT EXISTS convoy;
          CREATE USER IF NOT EXISTS 'convoy'@'localhost' IDENTIFIED BY '${dbPassword}';
          GRANT ALL PRIVILEGES ON convoy.* TO 'convoy'@'localhost';
          FLUSH PRIVILEGES;
        EOF
      '';
    };
  };

  systemd.services.convoy-composer-install = {
    description = "Install PHP dependencies with Composer";
    wantedBy = [ "multi-user.target" ];
    after = [ "convoy-panel-install.service" ];
    serviceConfig = {
      Type = "oneshot";
      WorkingDirectory = "/var/lib/convoy-panel";
      User = "nginx";
      Group = "nginx";
      Environment = "HOME=/var/lib/convoy-panel";
      ExecStart = pkgs.writeShellScript "composer-install" ''
        set -eux
        ${pkgs.php82Packages.composer}/bin/composer install --no-dev --no-interaction --prefer-dist
      '';
    };
  };

  systemd.services.convoy-migrate = {
    description = "Run Laravel migrations";
    wantedBy = [ "multi-user.target" ];
    after = [ "mysql.service" "convoy-db-setup.service" "convoy-composer-install.service" ];
    serviceConfig = {
      Type = "oneshot";
      WorkingDirectory = "/var/lib/convoy-panel";
      User = "nginx";
      Group = "nginx";
      ExecStart = "${phpPkg}/bin/php artisan migrate --force";
    };
  };

  systemd.services.convoy-create-admin = lib.mkIf createDefaultUser {
    description = "Create default Convoy admin user";
    wantedBy = [ "multi-user.target" ];
    after = [ "convoy-migrate.service" ];
    serviceConfig = {
      Type = "oneshot";
      WorkingDirectory = "/var/lib/convoy-panel";
      User = "nginx";
      Group = "nginx";
      ExecStart = "${phpPkg}/bin/php artisan c:user:make --email=${defaultUserEmail} --password=${defaultUserPassword}";
    };
  };

  systemd.services.convoy-queue-worker = {
    description = "Laravel Queue Worker";
    wantedBy = [ "multi-user.target" ];
    after = [ "convoy-create-admin.service" "redis.convoy.service" ];
    unitConfig = {
      ConditionPathExists = "/var/lib/convoy-panel/.env";
    };
    serviceConfig = {
      User = "nginx";
      Group = "nginx";
      WorkingDirectory = "/var/lib/convoy-panel";
      ExecStart = "${phpPkg}/bin/php artisan queue:work --queue=high,standard,low --sleep=3 --tries=3";
      Restart = "always";
      RestartSec = "5s";
    };
  };
}