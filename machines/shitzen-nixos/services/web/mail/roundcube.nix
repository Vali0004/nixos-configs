{ config
, pkgs
, ... }:

{
  services.nginx.virtualHosts."mail.fuckk.lol" = {
    enableACME = true;
    forceSSL = true;
    root = pkgs.roundcube;
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

  services.nginx.virtualHosts."mail.nanitehosting.com" = {
    enableACME = true;
    forceSSL = true;
    root = pkgs.roundcube;
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

  services.roundcube = {
    enable = true;
    configureNginx = false;
    hostName = "mail.fuckk.lol";
    extraConfig = ''
      $config['default_host'] = 'ssl://mail.fuckk.lol';
      $config['default_port'] = 993;
      $config['smtp_host'] = 'tls://mail.fuckk.lol';
      $config['smtp_port'] = 587;
      $config['smtp_secure'] = 'tls';
      $config['smtp_user'] = "%u";
      $config['smtp_pass'] = "%p";
      $config['smtp_log'] = true;
      $config['log_driver'] = 'file';
      $config['log_dir'] = '/tmp';
      $config['imap_conn_options'] = [
        'ssl' => [
          'verify_peer'       => true,
          'verify_peer_name'  => true,
          'allow_self_signed' => true,
        ],
      ];
    '';
  };
}