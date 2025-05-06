{ config, inputs, lib, pkgs, ... }:

{
  services.wings = {
    enable = true;
    tokenFile = "/data/private/secret/wingsFile";
    config = {
      uuid = "85da3dd7-7d31-4f60-9dc0-b06212f248cc";
      token_id = "fmtcooaiB2dEnGPO";
      remote = "https://panel.r33.live";
      api = {
        host = "0.0.0.0";
        port = 9000;
        ssl = {
          enabled = true;
          cert = "/var/lib/acme/unison.fuckk.lol/fullchain.pem";
          key = "/var/lib/acme/unison.fuckk.lol/key.pem";
        };
      };
      system = {
        root_directory = "/data/pterodactyl/data";
        log_directory = "/data/pterodactyl/logs";
        data = "/data/pterodactyl/data/volumes";
        archive_directory = "/data/pterodactyl/data/archives";
        backup_directory = "/data/pterodactyl/data/backups";
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

  virtualisation = {
    docker.enable = true;
  };
}