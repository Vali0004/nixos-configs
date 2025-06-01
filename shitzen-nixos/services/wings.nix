{ config, inputs, lib, pkgs, ... }:

{
  services.wings = {
    enable = true;
    tokenFile = config.age.secrets.pterodactyl.path;
    config = {
      uuid = "7493f305-63fb-4047-b8e4-136435e6180a";
      token_id = "5oz7AoZJENydrkoX";
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
        root_directory = "/data/pterodactyl/data";
        log_directory = "/data/pterodactyl/logs";
        data = "/data/pterodactyl/data/volumes";
        archive_directory = "/data/pterodactyl/data/archives";
        backup_directory = "/data/pterodactyl/data/backups";
        sftp = {
          bind_port = 2022;
        };
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