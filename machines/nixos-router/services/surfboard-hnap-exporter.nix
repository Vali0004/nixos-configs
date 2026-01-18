{ pkgs
, ... }:

{
  networking.firewall.allowedTCPPorts = [
    9712
  ];

  systemd.services.surfboard-hnap-exporter = {
    description = "S34 DOCSIS 3.1 Prometheus Exporter";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    requires = [ "network-online.target" ];

    serviceConfig = {
      ExecStart = "${pkgs.nodejs_24}/bin/node ${pkgs.surfboard-hnap-exporter}/lib/node_modules/surfboard-hnap-exporter/exporter.js";
      Restart = "always";
      RestartSec = 2;

      Environment = [
        "\"PORT=9712\""
        "\"MODEM_HOST=192.168.100.1\""
        "\"PASSWORD=YouKids773415$\""
      ];

      User = "root";
      Group = "root";
    };
  };
}