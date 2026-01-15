{ config
, ... }:

{
  mailserver = {
    domains = [
      "fuckk.lol"
      "nanitehosting.com"
    ];
    enable = true;
    enableImap = true;
    enableImapSsl = true;
    enableSubmission = true;
    enableSubmissionSsl = true;
    enablePop3Ssl = true;
    fqdn = "mail.fuckk.lol";
    # nix-shell -p mkpasswd --run 'mkpasswd -sm bcrypt'
    loginAccounts = {
      "vali@fuckk.lol" = {
        hashedPasswordFile = config.age.secrets.vali-fuckk-lol.path;
        aliases = [
          "abuse@fuckk.lol"
          "admin@fuckk.lol"
          "postmaster@fuckk.lol"
          "abuse@nanitehosting.com"
          "admin@nanitehosting.com"
          "postmaster@nanitehosting.com"
        ];
      };
      "do-not-reply@fuckk-lol".hashedPasswordFile = config.age.secrets.do-not-reply-fuckk-lol.path;
      "cleclerc@nanitehosting.com".hashedPasswordFile = config.age.secrets.cleclerc-nanitehosting-com.path;
    };
    mailDirectory = "/var/vmail";
    openFirewall = true;
    stateVersion = 3;
    systemDomain = "fuckk.lol";
    systemName = "nixos-mailserver";
    x509.useACMEHost = config.mailserver.fqdn;
  };
}