{ config
, pkgs
, ... }:

let
  addr = "0.0.0.0";
  port = 9135;

  listenAddr = "192.168.100.2";
  listenPort = 6110;

  timeout = "60s";

  dataDir = config.services.rtorrent.dataDir;
in {
  config = {
    systemd.services = {
      rtorrent-exporter = {
        enable = true;
        description = "RuTorrent Prometheus Exporter";
        serviceConfig = {
          ExecStart = "${pkgs.rtorrent-exporter}/bin/rtorrent-exporter --logtostderr=true --rtorrent.addr http://${listenAddr}:${toString (listenPort)}/RPC2 --telemetry.addr ${addr}:${toString (port)} --telemetry.timeout ${timeout} --config ${dataDir}/.rtorrent-exporter.yaml";
          Restart = "always";
          SupplementaryGroups = [ config.services.rtorrent.group ];
        };
        wantedBy = [ "multi-user.target" ];
      };
      rtorrent-private-exporter = {
        enable = true;
        description = "RuTorrent (Private) Prometheus Exporter";
        serviceConfig = {
          ExecStart = "${pkgs.rtorrent-exporter}/bin/rtorrent-exporter --logtostderr=true --rtorrent.addr http://${listenAddr}:${toString (listenPort + 1)}/RPC2 --telemetry.addr ${addr}:${toString (port + 1)} --telemetry.timeout ${timeout} --config ${dataDir}-private/.rtorrent-private-exporter.yaml";
          Restart = "always";
          SupplementaryGroups = [ config.services.rtorrent.group ];
        };
        wantedBy = [ "multi-user.target" ];
      };
    };

    # Cursed hack to allow for rtorrent-exporter to connect to the socket
    services.nginx = {
      enable = true;
      virtualHosts = {
        "rtorrent.localnet" = {
          forceSSL = false;
          listen = [{ addr = "0.0.0.0"; port = listenPort; }];
          locations."/RPC2".extraConfig = ''
            include ${config.services.nginx.package}/conf/scgi_params;
            scgi_pass unix:${config.services.rtorrent.rpcSocket};
          '';
        };
        "rtorrent-private.localnet" = {
          forceSSL = false;
          listen = [{ addr = "0.0.0.0"; port = listenPort + 1; }];
          locations."/RPC2".extraConfig = ''
            include ${config.services.nginx.package}/conf/scgi_params;
            scgi_pass unix:/run/rtorrent-private/rpc.sock;
          '';
        };
      };
    };
  };
}