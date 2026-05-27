{ config
, lib
, ... }:

{
  services.sonarr = {
    enable = true;
    user = "arr";
    group = config.services.rtorrent.group;
    openFirewall = true;
    settings = {
      update.mechanism = "builtIn";
      server = {
        port = 8989;
        bindaddress = "*";
      };
    };
  };

  networking.firewall.interfaces.enp3s0.allowedTCPPorts = (lib.optionals config.services.sonarr.enable [
    config.services.sonarr.settings.server.port
  ]);

  systemd.services.radarr.serviceConfig.SupplementaryGroups = [ config.services.rtorrent.group ];

  services.nginx.virtualHosts."sonarr.lab004.dev" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = lib.mkProxy {
      ip = "192.168.100.1";
      port = config.services.sonarr.settings.server.port;
    };
  };
}