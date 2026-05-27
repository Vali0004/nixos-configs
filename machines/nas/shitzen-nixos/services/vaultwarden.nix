{ config
, lib
, ... }:

{
  environment.systemPackages = [
    config.services.vaultwarden.package
  ];

  services.vaultwarden = {
    enable = true;
    config = {
      SIGNUPS_ALLOWED = false;

      ROCKET_ADDRESS = "0.0.0.0";
      ROCKET_PORT = 8222;
      ROCKET_LOG = "critical";

      SMTP_HOST = "mail.lab004.dev";
      SMTP_SECURITY = "force_tls";
      SMTP_PORT = 465;

      SMTP_FROM = "do-not-reply@lab004.dev";
      SMTP_FROM_NAME = "Kurisu's Bitwarden";
    };
    configurePostgres = true;
    dbBackend = "postgresql";
    domain = null; # we support local and non-local
    environmentFile = config.age.secrets.vaultwarden.path;
  };

  services.nginx.virtualHosts."vaultwarden.lab004.dev" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = lib.mkProxy {
      https = true;
      ip = "192.168.100.1";
      port = config.services.vaultwarden.config.ROCKET_PORT;
      webSockets = true;
    };
  };

  networking.firewall.interfaces.enp3s0.allowedTCPPorts = (lib.optionals config.services.vaultwarden.enable [
    config.services.vaultwarden.config.ROCKET_PORT
  ]);
}