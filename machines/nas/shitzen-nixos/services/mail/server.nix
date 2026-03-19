{ config
, pkgs
, ... }:

{
  environment.systemPackages = with pkgs; [
    openssl
  ];

  services.nginx.virtualHosts."mail.lab004.dev" = {
    forceSSL = true;
    enableACME = true;
  };

  mailserver = {
    domains = [
      "fuckk.lol"
      "lab004.dev"
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
      "vali@lab004.dev" = {
        hashedPasswordFile = config.age.secrets.vali-kursu-dev.path;
        aliases = [
          "abuse@lab004.dev"
          "admin@lab004.dev"
          "postmaster@lab004.dev"
          "vali@fuckk.lol"
          "abuse@fuckk.lol"
          "admin@fuckk.lol"
          "postmaster@fuckk.lol"
        ];
      };
      "do-not-reply@lab004.dev" = {
        hashedPasswordFile = config.age.secrets.do-not-reply-kursu-dev.path;
        aliases = [
          "no-reply@lab004.dev"
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
    systemDomain = "lab004.dev";
    systemName = config.networking.hostName;
    x509.useACMEHost = config.mailserver.fqdn;
  };
}