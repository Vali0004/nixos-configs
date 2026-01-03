{ config
, pkgs
, lib
, ... }:

let
  domain = "billing.fuckk.lol";

  whmcsRoot = "/var/lib/whmcs";

  dbName = "whmcs";
  dbUser = "whmcs";

  dbPassFile = config.age.secrets.whcms-db-pass.path;
  php = pkgs.php83.withExtensions ({ all, ... }: with all; [
    bcmath
    curl
    fileinfo
    filter
    gd
    gmp
    intl
    mbstring
    openssl
    pdo
    pdo_mysql
    session
    zip
  ]);
  ioncube = pkgs.php83Extensions.ioncube-loader;
in {
  services.nginx.virtualHosts.${domain} = {
    forceSSL = true;
    enableACME = true;

    root = whmcsRoot;

    extraConfig = ''
      index index.php index.html;
    '';
    locations = {
      "/" = {
        tryFiles = "$uri $uri/ /index.php?$args";
      };
      "~ \\.php$" = {
        extraConfig = ''
          include ${pkgs.nginx}/conf/fastcgi_params;
          fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
          fastcgi_pass unix:${config.services.phpfpm.pools.whmcs.socket};
        '';
      };
      "~* /(configuration\\.php|\\.env|\\.git|composer\\.(json|lock)|vendor/|storage/)" = {
        extraConfig = "deny all;";
      };
    };
  };

  services.phpfpm.pools.whmcs = {
    user = "nginx";
    group = "nginx";
    phpPackage = php;
    phpOptions = ''
      zend_extension=${ioncube}/lib/php/extensions/ioncube-loader.so
      max_execution_time = 200
      memory_limit = 256M
      upload_max_filesize = 64M
      post_max_size = 64M
    '';
    settings = {
      "listen.owner" = "nginx";
      "listen.group" = "nginx";
      "pm" = "dynamic";
      "pm.max_children" = 20;
      "pm.start_servers" = 2;
      "pm.min_spare_servers" = 2;
      "pm.max_spare_servers" = 6;
    };
  };

  systemd.tmpfiles.rules = [
    "d ${whmcsRoot} 0750 nginx nginx - -"
  ];

  systemd.services.whmcs-db-init = {
    description = "Initialize WHMCS MariaDB database and user";
    after = [ "mysql.service" ];
    wants = [ "mysql.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      set -euo pipefail

      PASS="$(cat ${dbPassFile})"

      ${pkgs.mariadb}/bin/mysql --protocol=socket -u root <<SQL
CREATE DATABASE IF NOT EXISTS \`${dbName}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${dbUser}'@'localhost' IDENTIFIED BY '${"$"}{PASS}';
GRANT ALL PRIVILEGES ON \`${dbName}\`.* TO '${dbUser}'@'localhost';
FLUSH PRIVILEGES;
SQL
    '';
  };
}