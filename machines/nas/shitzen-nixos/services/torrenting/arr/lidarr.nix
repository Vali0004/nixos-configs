{ config
, lib
, ... }:

{
  services.lidarr = {
    enable = true;
    user = "arr";
    group = config.services.rtorrent.group;
    openFirewall = true;
    settings = {
      update.mechanism = "builtIn";
      server = {
        port = 8686;
        bindaddress = "*";
      };
    };
  };

  networking.firewall.interfaces.enp3s0.allowedTCPPorts = (lib.optionals config.services.lidarr.enable [
    config.services.lidarr.settings.server.port
  ]);

  systemd.services.lidarr.serviceConfig.SupplementaryGroups = [ config.services.rtorrent.group ];

  services.nginx.virtualHosts."lidarr.lab004.dev" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = lib.mkProxy {
      ip = "192.168.100.1";
      port = config.services.lidarr.settings.server.port;
    };
  };
}