{ config
, lib
, ... }:

{
  services.kavita = {
    enable = true;
    settings.Port = 8788;
    tokenKeyFile = config.age.secrets.kavita.path;
  };

  networking.firewall.interfaces.enp3s0.allowedTCPPorts = (lib.optionals config.services.kavita.enable [
    config.services.kavita.settings.Port
  ]);

  services.nginx.virtualHosts."manga.lab004.dev" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = lib.mkProxy {
      ip = "192.168.100.1";
      port = config.services.kavita.settings.Port;
    };
  };
}