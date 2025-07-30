{ config, pkgs, lib, ... }:

let
  dht-port = 6990;
  peer-port = 50000;
  web-port = 3700;
in {
  services.rtorrent = {
    configText = ''
      dht = on
      dht_port = ${toString dht-port}
      encryption = allow_incoming,enable_retry,prefer_plaintext
      method.redirect=load.throw,load.normal
      method.redirect=load.start_throw,load.start
      method.insert=d.down.sequential,value|const,0
      method.insert=d.down.sequential.set,value|const,0
    '';
    downloadDir = "/data/services/downloads/rtorrent";
    enable = true;
    port = peer-port;
    openFirewall = true;
  };

  services.flood = {
    enable = true;
    port = web-port;
    openFirewall = true;
    extraArgs = ["--rtsocket=${config.services.rtorrent.rpcSocket}"];
  };

  services.nginx.virtualHosts."flood.fuckk.lol" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString web-port}";
      proxyWebsockets = true;
    };
  };

  systemd.services.flood.serviceConfig.SupplementaryGroups = [ config.services.rtorrent.group ];
  systemd.services.flood.serviceConfig.ReadWritePaths = [ "/data/private/Media" "/data/services/downloads/rtorrent" ];
  systemd.services.rtorrent.serviceConfig.ReadWritePaths = [ "/data/private/Media" "/data/services/downloads/rtorrent" ];
}