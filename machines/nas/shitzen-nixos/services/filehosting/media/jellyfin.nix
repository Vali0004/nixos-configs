{ config
, lib
, pkgs
, ... }:

{
  environment.systemPackages = [ pkgs.jellyfin-ffmpeg ];

  services.jellyfin = {
    enable = true;
    openFirewall = true;
    group = config.services.rtorrent.group;
    user = "arr";
  };

  networking.firewall.interfaces.enp3s0.allowedTCPPorts = (lib.optionals config.services.jellyfin.enable [
    8096
  ]);

  users.users.arr = {
    isSystemUser = true;
    group = "rtorrent";
  };

  services.nginx.virtualHosts."watch.furryporn.ca" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = lib.mkProxy {
      ip = "192.168.100.1";
      port = 8096;
    };
  };

  services.nginx.virtualHosts."media.lab004.dev" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = lib.mkProxy {
      ip = "192.168.100.1";
      port = 8096;
    };
  };

  systemd.services.jellyfin.serviceConfig.SupplementaryGroups = [
    config.services.rtorrent.group
    "video"
    "render"
  ];
}