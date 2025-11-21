{ config
, pkgs
, ... }:

{
  services.nginx.virtualHosts."${config.services.nextcloud.hostName}" = {
    forceSSL = true;
    enableACME = true;
  };

  services.nextcloud = {
    database.createLocally = true;
    config = {
      adminuser = "Vali";
      adminpassFile = config.age.secrets.nextcloud-admin-password.path;
      dbtype = "pgsql";
      overwriteProtocol = "https";
    };
    configureRedis = true;
    settings.log_type = "systemd";
    enable = true;
    home = "/data/services/nextcloud";
    hostName = "cloud.fuckk.lol";
    https = true;
    maxUploadSize = "16G";
    package = pkgs.nextcloud32;
  };
}