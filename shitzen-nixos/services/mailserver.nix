{ config, inputs, lib, pkgs, ... }:

{
  mailserver = {
    certificateScheme = "acme-nginx";
    domains = [
      "fuckk.lol"
      "nanitehosting.com"
    ];
    enable = true;
    enableImap = false;
    enableImapSsl = true;
    enableSubmission = true;
    enableSubmissionSsl = true;
    enablePop3Ssl = true;
    fqdn = "mail.fuckk.lol";
    # nix-shell -p mkpasswd --run 'mkpasswd -sm bcrypt'
    loginAccounts = {
      "vali@fuckk.lol" = {
        hashedPasswordFile = config.age.secrets.vali-mail-fuckk-lol.path;
        aliases = [
          "abuse@fuckk.lol"
          "admin@fuckk.lol"
          "postmaster@fuckk.lol"
          "abuse@nanitehosting.com"
          "admin@nanitehosting.com"
          "postmaster@nanitehosting.com"
        ];
      };
      "cleclerc@nanitehosting.com" = {
        hashedPasswordFile = config.age.secrets.cleclerc-mail-nanitehosting-com.path;
      };
      "maddy@fuckk.lol" = {
        hashedPasswordFile = config.age.secrets.maddy-mail-fuckk-lol.path;
      };
      "proxy@fuckk.lol" = {
        hashedPasswordFile = config.age.secrets.proxy-mail-fuckk-lol.path;
      };
    };
    mailDirectory = "/var/vmail";
    openFirewall = true;
    stateVersion = 3;
    systemDomain = "fuckk.lol";
    systemName = "nixos-mailserver";
  };

  services.nginx.virtualHosts."mail.fuckk.lol" = {
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

  services.nginx.virtualHosts."mail.nanitehosting.com" = {
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

  services.roundcube = {
    enable = true;
    configureNginx = false;
    hostName = "mail.fuckk.lol";
    extraConfig = ''
      $config['default_host'] = 'ssl://192.168.100.2';
      $config['default_port'] = 993;
      $config['smtp_host'] = "mail.fuckk.lol";
      $config['smtp_port'] = 587;
      $config['smtp_secure'] = 'tls';
      $config['smtp_user'] = "%u";
      $config['smtp_pass'] = "%p";
      $config['debug_level'] = 4;
      $config['smtp_log'] = true;
      $config['log_driver'] = 'file';
      $config['log_dir'] = '/tmp';
      $config['imap_conn_options'] = [
        'ssl' => [
          'verify_peer'       => false,
          'verify_peer_name'  => false,
          'allow_self_signed' => true,
        ],
      ];
    '';
  };
}