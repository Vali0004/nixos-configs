{ config, inputs, lib, pkgs, ... }:

let
  mkProxy = import ../modules/mkproxy.nix;
in {
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
    locations."/" = mkProxy {
      port = 8096;
    };
  };

  services.nginx.virtualHosts."watch.furryporn.ca" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = mkProxy {
      port = 8096;
    };
  };

  systemd.services.jellyfin.serviceConfig.SupplementaryGroups = [
    config.services.rtorrent.group
    "video"
    "render"
  ];
}