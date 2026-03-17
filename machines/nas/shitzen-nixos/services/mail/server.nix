{ config
, pkgs
, ... }:

{
  environment.systemPackages = with pkgs; [
    openssl
  ];

  services.nginx.virtualHosts."mail.kursu.dev" = {
    forceSSL = true;
    enableACME = true;
  };

  mailserver = {
    domains = [
      "fuckk.lol"
      "kursu.dev"
      "nanitehosting.com"
    ];
    enable = true;
    enableImap = true;
    enableImapSsl = true;
    enableSubmission = true;
    enableSubmissionSsl = true;
    enablePop3Ssl = true;
    fqdn = "mail.${config.mailserver.systemDomain}";
    # nix-shell -p mkpasswd --run 'mkpasswd -sm bcrypt'
    loginAccounts = {
      "vali@kursu.dev" = {
        hashedPasswordFile = config.age.secrets.vali-kursu-dev.path;
        aliases = [
          "abuse@kursu.dev"
          "admin@kursu.dev"
          "postmaster@kursu.dev"
          "vali@fuckk.lol"
          "abuse@fuckk.lol"
          "admin@fuckk.lol"
          "postmaster@fuckk.lol"
        ];
      };
      "do-not-reply@kursu.dev" = {
        hashedPasswordFile = config.age.secrets.do-not-reply-kursu-dev.path;
        aliases = [
          "no-reply@kursu.dev"
          "do-not-reply@fuckk.lol"
          "no-reply@fuckk.lol"
        ];
      };
      "cleclerc@nanitehosting.com" = {
        hashedPasswordFile = config.age.secrets.cleclerc-nanitehosting-com.path;
        aliases = [
          "abuse@nanitehosting.com"
          "admin@nanitehosting.com"
          "postmaster@nanitehosting.com"
        ];
      };
    };
    mailDirectory = "/var/vmail";
    openFirewall = true;
    stateVersion = 3;
    systemDomain = "kursu.dev";
    systemName = config.networking.hostName;
    x509.useACMEHost = config.mailserver.fqdn;
  };
}