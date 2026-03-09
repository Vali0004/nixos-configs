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

  services.nginx.virtualHosts."ohh.fuckk.lol" = {
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