{ config, lib, pkgs, ... }:

let
  php-env = pkgs.php.buildEnv {
    extensions = { enabled, all }: with all; enabled ++ [
      memcached redis mbstring bcmath mysqli curl zip gd
    ];
    extraConfig = ''
      memory_limit = 256M
    '';
  };
in {
  services.phpfpm.pools.pterodactyl = {
    user = "nginx";
    group = "nginx";
    settings = {
      "listen.owner" = config.services.nginx.user;
      "pm" = "dynamic";
      "pm.max_children" = 5;
      "pm.start_servers" = 2;
      "pm.min_spare_servers" = 1;
      "pm.max_spare_servers" = 3;
      "pm.max_requests" = 500;
    };
    phpEnv."PATH" = lib.makeBinPath [ php-env ];
    phpPackage = php-env;
  };

  systemd.services.pterodactyl-panel-scheduler = {
    description = "Pterodactyl Panel";
    after = [ "redis-pterodactyl.service" ];
    wantedBy = [ "multi-user.target" ];
    unitConfig = {
      ConditionPathExists = "/var/lib/pterodactyl-panel/.env";
      ConditionDirectoryNotEmpty = "/var/lib/pterodactyl-panel/vendor";
      StartLimitInterval = "180";
    };
    serviceConfig = {
      User = "nginx";
      Group = "nginx";
      SyslogIdentifier = "pterodactyl-panel-scheduler";
      WorkingDirectory = "/var/lib/pterodactyl-panel";
      ExecStart = "${config.services.phpfpm.phpPackage}/bin/php artisan queue:work --queue=high,standard,low --sleep=3 --tries=3";

      StartLimitBurst = "30";
      RestartSec = "5s";
      Restart = "always";
    };
  };

  services.nginx.virtualHosts."panel.fuckk.lol" = {
    enableACME = true;
    forceSSL = true;
    root = "/var/lib/pterodactyl-panel/public";
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
}