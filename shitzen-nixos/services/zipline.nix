{ config, inputs, lib, pkgs, ... }:

let
  mkProxy = import ./nginx/mkproxy.nix;
in {
  environment.systemPackages = [ pkgs.zipline ];
  services.nginx.virtualHosts = {
    # Zipline
    "holy.fuckk.lol" = {
      enableACME = true;
      forceSSL = true;
      locations = {
        "/" = mkProxy {
          port = 3000;
          webSockets = true;
        };
      };
    };
  };
  services.zipline = {
    enable = true;
    environmentFiles = [
      config.age.secrets.zipline.path
    ];
    settings = {
      CORE_HOSTNAME = "0.0.0.0";
      CORE_PORT = 3000;
      DATASOURCE_LOCAL_DIRECTORY = "/data/zipline/uploads";
      DATASOURCE_TYPE = "local";
    };
  };
  systemd.services.zipline = {
    serviceConfig.ReadWritePaths = [ "/data/zipline/uploads" ];
  };
}