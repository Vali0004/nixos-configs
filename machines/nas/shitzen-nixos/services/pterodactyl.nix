{ config
, lib
, ... }:

{
  services.pterodactyl = {
    enable = true;
    domain = "hosting.lab004.dev";
    database = {
      passwordFile = config.age.secrets.pterodactyl-db.path;
    };
    admin.username = "Vali";
    wings = {
      enable = true;
      tokenFile = config.age.secrets.pterodactyl.path;
      config = {
        uuid = "82a386e1-d6ff-40e6-b631-13baa2023914";
        token_id = "6Yp6x0wccMXEkYbX";
        remote = "https://${config.services.pterodactyl.domain}";
        api = {
          host = "0.0.0.0";
          port = 8900;
          ssl = {
            enabled = true;
            cert = "/var/lib/acme/shitzen-nixos.lab004.dev/fullchain.pem";
            key = "/var/lib/acme/shitzen-nixos.lab004.dev/key.pem";
          };
          upload_limit = 100;
        };
        system = {
          root_directory = "${config.services.pterodactyl.dataDir}/data";
          log_directory = "${config.services.pterodactyl.dataDir}/logs";
          data = "${config.services.pterodactyl.dataDir}/data/volumes";
          archive_directory = "${config.services.pterodactyl.dataDir}/data/archives";
          backup_directory = "${config.services.pterodactyl.dataDir}/data/backups";
          sftp.bind_port = 2022;
        };
      };
    };
  };

  services.nginx.virtualHosts."shitzen-nixos.lab004.dev" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = lib.mkProxy {
      https = true;
      ip = "192.168.100.1";
      port = 8900;
      webSockets = true;
    };
  };

  networking.firewall = {
    allowedTCPPorts = [
      8900
      8901
      8902
      8903
      8904
    ];
    allowedUDPPorts = [
      8901
      8902
      8903
      8904
    ];
  };
}