{ config
, lib
, ... }:

{
  services.radarr = {
    enable = true;
    user = "arr";
    group = config.services.rtorrent.group;
    openFirewall = true;
    settings = {
      update.mechanism = "builtIn";
      server = {
        port = 7878;
        bindaddress = "*";
      };
    };
  };

  networking.firewall.interfaces.enp3s0.allowedTCPPorts = (lib.optionals config.services.radarr.enable [
    config.services.radarr.settings.server.port
  ]);

  systemd.services.radarr.serviceConfig.SupplementaryGroups = [ config.services.rtorrent.group ];

  services.nginx.virtualHosts."radarr.lab004.dev" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = lib.mkProxy {
      ip = "192.168.100.1";
      port = config.services.radarr.settings.server.port;
    };
  };
}