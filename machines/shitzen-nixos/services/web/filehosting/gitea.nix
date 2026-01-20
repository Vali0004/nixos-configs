{ config
, lib
, pkgs
, ... }:

{
  networking.firewall.allowedTCPPorts = [
    2222
  ];

  services.gitea = {
    appName = "kursu.dev: Git";
    captcha.enable = true;
    database = {
      createDatabase = true;
      passwordFile = config.age.secrets.git-kursu-dev-db.path;
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
    mailerPasswordFile = config.age.secrets.do-not-reply-kursu-dev.path;
    settings = {
      actions.ENABLED = true;
      "cron.sync_external_users" = {
        RUN_AT_START = true;
        SCHEDULE = "@every 24h";
        UPDATE_EXISTING = true;
      };
      log.LEVEL = "Error";
      mailer = {
        ENABLED = true;
        PROTOCOL = "smtps";
        SMTP_ADDR = "mail.kursu.dev";
        SMTP_PORT = "465";
        FROM = "Kursu's Git Service <do-not-reply@kursu.dev>";
        USER = "do-not-reply@kursu.dev";
      };
      metrics.ENABLED = false;
      other = {
        SHOW_FOOTER_VERSION = false;
      };
      server = {
        DOMAIN = "git.kursu.dev";
        HTTP_PORT = 3900;
        HTTP_ADDR = "0.0.0.0";
        ROOT_URL = "https://git.kursu.dev";
        SSH_DOMAIN = "git.kursu.dev";
        SSH_PORT = 2222;
        SSH_CREATE_AUTHORIZED_KEYS_FILE = true;
        START_SSH_SERVER = true;
      };
      service = {
        DISABLE_REGISTRATION = false;
        ENABLE_NOTIFY_MAIL = true;
      };
      session = {
        COOKIE_SECURE = true;
        PROVIDER = "db";
      };
      "ssh.minimum_key_sizes".RSA = 2048;
      ui.ONLY_SHOW_RELEVANT_REPOS = true;
    };
    stateDir = "/var/lib/git";
    user = "git";
  };

  services.nginx.virtualHosts."git.kursu.dev" = {
    enableACME = true;
    forceSSL = true;

    # Ask robots not to scrape Git, it has various expensive endpoints
    locations."=/robots.txt".alias = pkgs.writeText "git.kursu.dev-robots.txt" ''
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

  systemd.services.gitea.serviceConfig = lib.mkNamespace {};

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