{ config, inputs, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    jellyfin-ffmpeg
  ];

  services.jellyfin = {
    enable = true;
    openFirewall = true;
    group = "rtorrent";
  };

  services.nginx.virtualHosts."ohh.fuckk.lol" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://192.168.100.1:8096";
      proxyWebsockets = true;
    };
  };

  systemd.services.jellyfin.serviceConfig.SupplementaryGroups = [
    config.services.rtorrent.group
    "video"
    "render"
  ];
}