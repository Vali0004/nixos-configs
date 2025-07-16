{ config, inputs, lib, pkgs, ... }:

{
  mailserver = {
    enable = true;
    fqdn = "smtp.fuckk.lol";
    domains = [ "fuckk.lol" ];

    # A list of all login accounts. To create the password hashes, use
    # nix-shell -p mkpasswd --run 'mkpasswd -sm bcrypt'
    loginAccounts = {
      "vali@fuckk.lol" = {
        hashedPasswordFile = "/var/lib/mail/valiPass";
        aliases = [ "admin@fuckk.lol" ];
      };
      #"unison@fuckk.lol" = { ... };
    };

    certificateScheme = "acme-nginx";
  };

  services.roundcube = {
     enable = true;
     configureNginx = false;
     hostName = "webmail.fuckk.lol";
     extraConfig = ''
       $config['smtp_host'] = "tls://${config.mailserver.fqdn}";
       $config['smtp_user'] = "%u";
       $config['smtp_pass'] = "%p";
     '';
  };
}