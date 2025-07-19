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