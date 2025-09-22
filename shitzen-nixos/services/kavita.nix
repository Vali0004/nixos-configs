{ config, pkgs, ... }:

{
  services.kavita = {
    enable = true;
    settings.Port = 8788;
  };

  services.nginx.virtualHosts."manga.fuckk.lol" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://192.168.100.1:8788";
      proxyWebsockets = true;
    };
  };
}