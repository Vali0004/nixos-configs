{ config
, lib
, pkgs
, ... }:

{
  services.gitea = {
    appName = "fuckk.lol: Git";
    captcha.enable = true;
    database = {
      createDatabase = true;
      passwordFile = config.age.secrets.git-fuckk-lol-db.path;
      name = config.services.gitea.user;
      port = 5432;
      type = "postgres";
      user = config.services.gitea.user;
    };
    enable = true;
    group = "git";
    lfs = {
      contentDir = "/data/services/git/lfs";
      enable = true;
    };
    mailerPasswordFile = config.age.secrets.do-not-reply-fuckk-lol.path;
    settings = {
      "cron.sync_external_users" = {
        RUN_AT_START = true;
        SCHEDULE = "@every 24h";
        UPDATE_EXISTING = true;
      };
      other = {
        SHOW_FOOTER_VERSION = false;
      };
      mailer = {
        ENABLED = true;
        PROTOCOL = "smtp+starttls";
        SMTP_ADDR = "mail.fuckk.lol";
        SMTP_PORT = "587";
        FROM = "Fuckk.lol's Git Service <do-not-reply@fuckk.lol>";
        USER = "do-not-reply@fuckk.lol";
      };
      server = {
        DOMAIN = "git.fuckk.lol";
        HTTP_PORT = 3900;
        HTTP_ADDR = "0.0.0.0";
        ROOT_URL = "https://git.fuckk.lol";
      };
      session.COOKIE_SECURE = true;
    };
    stateDir = "/var/lib/git";
    user = "git";
  };

  services.nginx.virtualHosts."git.fuckk.lol" = {
    enableACME = true;
    forceSSL = true;

    # Ask robots not to scrape Git, it has various expensive endpoints
    locations."=/robots.txt".alias = pkgs.writeText "git.fuckk.lol-robots.txt" ''
      User-agent: *
      Disallow: /
      Allow: /$
    '';

    locations."/" = lib.mkProxy {
      ip = "$upstream";
      hasPort = false;
      config = ''
        limit_req zone=git-server burst=5;
      '';
    };

    locations."~ ^(/build/\\d+/download/|/.*\\.git$)" = lib.mkProxy {
      ip = "git-server";
      hasPort = false;
    };

    locations."/static/" = {
      alias = config.services.gitea.settings.server.STATIC_ROOT_PATH;
    };
  };

  users = {
    users.git = {
      isSystemUser = true;
      createHome = true;
      home = "/var/lib/git";
      group = "git";
    };
    groups.git = {};
  };
}