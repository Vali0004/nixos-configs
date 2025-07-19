{ config, inputs, lib, pkgs, ... }:

{
  services.wings = {
    enable = true;
    tokenFile = config.age.secrets.pterodactyl.path;
    config = {
      uuid = "1e742838-97d6-438a-8d43-df3060fe9c6c";
      token_id = "VeLiTm6TTJPSzSfe";
      remote = "https://panel.fuckk.lol";
      api = {
        host = "0.0.0.0";
        port = 9000;
        ssl = {
          enabled = true;
          cert = "/var/lib/acme/unison.fuckk.lol/fullchain.pem";
          key = "/var/lib/acme/unison.fuckk.lol/key.pem";
        };
        upload_limit = 100;
      };
      system = {
        root_directory = "/data/services/pterodactyl/data";
        log_directory = "/data/services/pterodactyl/logs";
        data = "/data/services/pterodactyl/data/volumes";
        archive_directory = "/data/services/pterodactyl/data/archives";
        backup_directory = "/data/services/pterodactyl/data/backups";
        sftp.bind_port = 2022;
      };
    };
  };

  users = {
    groups.pterodactyl = {};
    users = {
      pterodactyl = {
        extraGroups = [ "docker" "nginx" ];
        group = "pterodactyl";
        isSystemUser = true;
      };
    };
  };
}