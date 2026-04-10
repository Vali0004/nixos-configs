{ config
, lib
, pkgs
, ... }:

let
  cfg = config.services.pterodactyl;

  php = pkgs.php.buildEnv {
    extensions = { enabled, all }: with all; enabled ++ [
      memcached redis mbstring bcmath mysqli curl zip gd
    ];
    extraConfig = ''
      memory_limit = 256M
    '';
  };

in {
  options.services.pterodactyl = {
    enable = lib.mkEnableOption "Pterodactyl (panel & wings)";

    domain = lib.mkOption {
      type = lib.types.str;
      example = "panel.example.com";
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/pterodactyl";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "pterodactyl";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "pterodactyl";
    };

    panelVersion = lib.mkOption {
      type = lib.types.str;
      default = "1.12.2";
    };

    database = {
      name = lib.mkOption {
        type = lib.types.str;
        default = "pterodactyl";
      };
      user = lib.mkOption {
        type = lib.types.str;
        default = "pterodactyl";
      };
      passwordFile = lib.mkOption {
        type = lib.types.path;
      };
    };

    admin = {
      username = lib.mkOption {
        type = lib.types.str;
        default = "admin";
      };
      password = lib.mkOption {
        type = lib.types.str;
        default = "admin";
        description = "It is recommended you change this after first login";
      };
    };

    wings = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };

      tokenFile = lib.mkOption {
        type = lib.types.path;
      };

      config = lib.mkOption {
        type = lib.types.attrs;
        default = {};
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.mysql = {
      enable = true;
      ensureDatabases = [ cfg.database.name ];
    };

    services.redis.servers.pterodactyl = {
      enable = true;
      port = 6379;
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0755 root root -"
      "d ${cfg.dataDir}/panel 0755 ${cfg.user} ${cfg.group} -"
    ];

    systemd.services.pterodactyl-db-init = {
      description = "Initialize Pterodactyl Database";
      after = [ "mysql.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
      };

      script = ''
        PASS=$(cat ${cfg.database.passwordFile})

        ${config.services.mysql.package}/bin/mariadb <<EOF
        CREATE USER IF NOT EXISTS '${cfg.database.user}'@'localhost' IDENTIFIED BY '$PASS';
        GRANT ALL PRIVILEGES ON ${cfg.database.name}.* TO '${cfg.database.user}'@'localhost';
        FLUSH PRIVILEGES;
        EOF
      '';
    };

    systemd.services.pterodactyl-fetch = {
      description = "Fetch Pterodactyl Panel";
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        User = cfg.user;
        WorkingDirectory = "${cfg.dataDir}/panel";
      };

      path = with pkgs; [ curl gnutar gzip nodejs_20 yarn config.services.mysql.package ];

      script = ''
        if [ ! -f artisan ]; then
          curl -L -o panel.tar.gz https://github.com/pterodactyl/panel/archive/refs/tags/v${cfg.panelVersion}.tar.gz
          tar -xzf panel.tar.gz --strip-components=1
          rm panel.tar.gz
        fi

        if [ ! -f public/build/manifest.json ] && [ ! -f public/mix-manifest.json ]; then
          yarn install --frozen-lockfile || yarn install
          yarn build
        fi
      '';
    };

    systemd.services.pterodactyl-composer = {
      description = "Install Pterodactyl Composer Dependencies";
      after = [ "pterodactyl-fetch.service" ];
      requires = [ "pterodactyl-fetch.service" ];
      wantedBy = [ "multi-user.target" ];

      path = [ php pkgs.phpPackages.composer ];

      serviceConfig = {
        Type = "oneshot";
        User = cfg.user;
        WorkingDirectory = "${cfg.dataDir}/panel";
      };

      script = ''
        if [ ! -d vendor ]; then
          composer install --no-interaction --prefer-dist
        fi
      '';
    };

    systemd.services.pterodactyl-env-patch = {
      description = "Patch Pterodactyl .env";
      after = [ "pterodactyl-composer.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        User = cfg.user;
        WorkingDirectory = "${cfg.dataDir}/panel";
      };

      script = ''
        set -euo pipefail

        if [ ! -f .env ]; then
          cp .env.example .env
          ${php}/bin/php artisan key:generate --force
        fi

        ENV=.env
        set_kv () {
          key="$1"
          value="$2"

          if grep -q "^''${key}=" "$ENV"; then
            sed -i "s|^''${key}=.*|''${key}=''${value}|g" "$ENV"
          else
            echo "''${key}=''${value}" >> "$ENV"
          fi
        }

        set_kv APP_ENV "production"
        set_kv APP_DEBUG "false"
        set_kv APP_URL "https://${cfg.domain}"
        set_kv DB_DATABASE "${cfg.database.name}"
        set_kv DB_USERNAME "${cfg.database.user}"

        DB_PASS=$(cat ${cfg.database.passwordFile})
        set_kv DB_PASSWORD "$DB_PASS"
        set_kv REDIS_HOST "127.0.0.1"
        set_kv REDIS_PORT "6379"
        set_kv CACHE_DRIVER "file"
        set_kv SESSION_DRIVER "file"
        set_kv QUEUE_CONNECTION "redis"

        echo "[pterodactyl] .env patched successfully"
      '';
    };

    systemd.services.pterodactyl-setup = {
      description = "Pterodactyl Laravel Bootstrap";
      after = [
        "pterodactyl-composer.service"
        "mysql.service"
        "redis-pterodactyl.service"
        "pterodactyl-env-patch.service"
      ];
      wantedBy = [ "multi-user.target" ];
      requires = [
        "pterodactyl-composer.service"
        "pterodactyl-env-patch.service"
      ];

      path = [ config.services.mysql.package ];

      serviceConfig = {
        Type = "oneshot";
        User = cfg.user;
        WorkingDirectory = "${cfg.dataDir}/panel";
      };

      script = ''
        ${php}/bin/php artisan config:clear
        ${php}/bin/php artisan migrate --seed --force
        ${php}/bin/php artisan config:cache

        if [ ! -f .admin_created ]; then
          ${php}/bin/php artisan p:user:make \
            --email "${cfg.admin.username}@${cfg.domain}" \
            --username "${cfg.admin.username}" \
            --name-first "${cfg.admin.username}" \
            --name-last "." \
            --password "${cfg.admin.password}" \
            --admin=1

          touch .admin_created
        fi
      '';
    };

    systemd.services.pterodactyl-worker = {
      description = "Pterodactyl Queue Worker";
      after = [ "pterodactyl-setup.service" ];

      serviceConfig = {
        User = cfg.user;
        WorkingDirectory = "${cfg.dataDir}/panel";
        ExecStart = "${php}/bin/php artisan queue:work --queue=high,standard,low --sleep=3 --tries=3";
        Restart = "always";
        RestartSec = "5s";
      };

      wantedBy = [ "multi-user.target" ];
    };

    services.phpfpm.pools.pterodactyl = {
      user = cfg.user;
      group = cfg.group;

      phpPackage = php;

      settings = {
        "pm" = "dynamic";
        "pm.max_children" = 5;
        "pm.start_servers" = 2;
        "pm.min_spare_servers" = 1;
        "pm.max_spare_servers" = 3;
        "listen.owner" = cfg.user;
        "listen.group" = config.services.nginx.group;
        "listen.mode" = "0660";
      };
    };

    services.nginx.enable = true;
    services.nginx.virtualHosts.${cfg.domain} = {
      enableACME = true;
      forceSSL = true;

      root = "${cfg.dataDir}/panel/public";

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
        fastcgi_pass unix:${config.services.phpfpm.pools.pterodactyl.socket};
        fastcgi_index index.php;
        fastcgi_param PHP_VALUE "upload_max_filesize = 100M \n post_max_size=100M";
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param HTTP_PROXY "";
        fastcgi_intercept_errors off;
        fastcgi_buffer_size 16k;
        fastcgi_buffers 4 16k;
        fastcgi_connect_timeout 300;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;
        include ${pkgs.nginx}/conf/fastcgi_params;
        include ${pkgs.nginx}/conf/fastcgi.conf;
      '';

      locations."~ /\\.ht".extraConfig = ''
        deny all;
      '';
    };

    services.wings = lib.mkIf cfg.wings.enable {
      enable = true;
      tokenFile = cfg.wings.tokenFile;
      config = cfg.wings.config;
    };
    users = {
      groups.${cfg.group}.members = [ "nginx" ];
      users = {
        ${cfg.user} = {
          isSystemUser = true;
          group = cfg.group;
          extraGroups = [ "nginx" "docker" ];
        };
        nginx.extraGroups = [ cfg.group ];
      };
    };
  };
}