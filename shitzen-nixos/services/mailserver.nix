{ config, inputs, lib, pkgs, ... }:

{
  mailserver = {
    certificateScheme = "acme-nginx";
    domains = [ "fuckk.lol" ];
    enable = true;
    fqdn = "smtp.fuckk.lol";
    # A list of all login accounts. To create the password hashes, use
    # nix-shell -p mkpasswd --run 'mkpasswd -sm bcrypt'
    loginAccounts = {
      "vali@fuckk.lol" = {
        hashedPasswordFile = config.age.secrets.vali-mail-fuckk-lol.path;
        aliases = [ "admin@fuckk.lol" ];
      };
      #"unison@fuckk.lol" = { ... };
    };
    mailDirectory = "/var/vmail";
    stateVersion = 3;
  };

  services.nginx.virtualHosts."webmail.fuckk.lol" = {
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

  services.nginx.virtualHosts."smtp.fuckk.lol" = {
    enableACME = true;
    forceSSL = true;
    locations."/".extraConfig = ''
      return 404;
    '';
  };

  services.roundcube = {
    enable = true;
    configureNginx = false;
    hostName = "webmail.fuckk.lol";
    extraConfig = ''
      $config['smtp_host'] = "smtp.fuckk.lol";
      $config['smtp_port'] = 587;
      $config['smtp_secure'] = 'tls';
      $config['smtp_user'] = "%u";
      $config['smtp_pass'] = "%p";
      $config['debug_level'] = 4;
      $config['smtp_log'] = true;
      $config['log_driver'] = 'file';
      $config['log_dir'] = '/tmp';
    '';
  };
}