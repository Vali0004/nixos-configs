{ config
, pkgs
, ... }:

let
  addr = "0.0.0.0";
  port = 9135;
  timeout = "60s";
in {
  config = {
    systemd.services.rtorrent-exporter = {
      enable = true;
      description = "RuTorrent Prometheus Exporter";
      serviceConfig = {
        ExecStart = "${pkgs.rtorrent-exporter}/bin/rtorrent-exporter --logtostderr=true --rtorrent.addr http://192.168.100.2:90/RPC2 --telemetry.addr ${addr}:${toString port} --telemetry.timeout ${timeout} --config /var/lib/rtorrent/.rtorrent-exporter.yaml";
        Restart = "always";
        SupplementaryGroups = [ config.services.rtorrent.group ];
      };
      wantedBy = [ "multi-user.target" ];
    };

    # Cursed hack to allow for rtorrent-exporter to connect to the socket
    services.nginx = {
      enable = true;
      virtualHosts."rtorrent.localnet" = {
        enableACME = false;
        forceSSL = false;
        listen = [{ addr = "192.168.100.2"; port = 90; }];
        locations."/RPC2".extraConfig = ''
          include ${config.services.nginx.package}/conf/scgi_params;
          scgi_pass unix:${config.services.rtorrent.rpcSocket};
        '';
      };
    };
  };
}