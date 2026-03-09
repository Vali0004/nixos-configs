{ config
, lib
, ... }:

{
  services.kavita = {
    enable = true;
    settings.Port = 8788;
    tokenKeyFile = config.age.secrets.kavita.path;
  };

  services.nginx.virtualHosts."manga.fuckk.lol" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = lib.mkProxy {
      ip = "192.168.100.1";
      port = config.services.kavita.settings.Port;
    };
  };
}