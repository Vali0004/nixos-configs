{ config
, lib
, pkgs
, ... }:

{
  services.zipline = {
    enable = true;
    environmentFiles = [ config.age.secrets.zipline.path ];
    settings = {
      CORE_HOSTNAME = "0.0.0.0";
      CORE_PORT = 3000;
      DATASOURCE_LOCAL_DIRECTORY = "/data/services/zipline/uploads";
      DATASOURCE_TYPE = "local";
    };
  };

  systemd.services.zipline.serviceConfig.ReadWritePaths = [ "/data/services/zipline/uploads" ];

  services.nginx.virtualHosts."cdn.nanite.gg" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = lib.mkProxy {
      ip = "192.168.100.1";
      port = config.services.zipline.settings.CORE_PORT;
      webSockets = true;
    };
  };

  services.nginx.virtualHosts."holy.fuckk.lol" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = lib.mkProxy {
      ip = "192.168.100.1";
      port = config.services.zipline.settings.CORE_PORT;
      webSockets = true;
    };
  };
}