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
}