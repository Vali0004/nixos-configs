{ config
, lib
, pkgs
, ... }:

{
  services.nginx.virtualHosts."${config.services.nextcloud.hostName}" = {
    forceSSL = true;
    enableACME = true;
    locations."/dashboard" = {
      return = "301 /apps/dashboard/";
    };
  };

  services.nextcloud = {
    enable = true;
    appstoreEnable = true;
    caching.redis = true;
    configureRedis = true;
    config = {
      adminuser = "Vali";
      adminpassFile = config.age.secrets.nextcloud-admin-password.path;
      dbtype = "pgsql";
    };
    database.createLocally = true;
    extraApps = {
      inherit (config.services.nextcloud.package.packages.apps) contacts calendar mail tasks;
    };
    extraAppsEnable = true;
    home = "/data/services/nextcloud";
    hostName = "cloud.kursu.dev";
    https = true;
    maxUploadSize = "16G";
    package = pkgs.nextcloud32;
    phpOptions = {
      "opcache.interned_strings_buffer" = "23";
    };
    settings = {
      overwriteprotocol = "https";
      default_phone_region = "US";
      log_type = "systemd";
      mail_smtpmode = "smtp";
      mail_smtphost = "mail.kursu.dev";
      mail_smtpauth = true;
    };
  };
}