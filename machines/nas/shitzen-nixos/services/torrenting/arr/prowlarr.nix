{ config
, lib
, ... }:

{
  services.prowlarr = {
    enable = true;
    openFirewall = true;
    settings = {
      update.mechanism = "builtIn";
      server = {
        port = 9696;
        bindaddress = "*";
      };
    };
  };

  networking.firewall.interfaces.enp3s0.allowedTCPPorts = (lib.optionals config.services.prowlarr.enable [
    config.services.prowlarr.settings.server.port
  ]);

  systemd.services.prowlarr.serviceConfig.SupplementaryGroups = [ config.services.rtorrent.group ];

  services.nginx.virtualHosts."prowlarr.lab004.dev" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = lib.mkProxy {
      ip = "192.168.100.1";
      port = config.services.prowlarr.settings.server.port;
    };
  };
}