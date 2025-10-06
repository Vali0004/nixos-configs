{ config, inputs, lib, pkgs, ... }:

let
  mkJob = import ../modules/mkprometheus.nix;
in {
  networking.firewall.allowedTCPPorts = [
    9100 # Node Exporter
  ];

  services.prometheus = {
    enable = true;
    enableReload = true;
    exporters.node = {
      enable = true;
      enabledCollectors = [
        "cpu"
        "filesystem"
        "interrupts"
        "loadavg"
        "meminfo"
        "netstat"
        "systemd"
        "systemd.enable-start-time-metrics"
        "zfs"
      ];
    };
    scrapeConfigs = [
      (mkJob {
        targets = [
          "LA-01-OVPN"
          "UK-01-OVPN"
          "Sweden-01-OVPN"
          "Amsterdam-01-OVPN"
          "Japan-01-OVPN"
          "France-01-OVPN"
          "Toronto-01-OVPN"
        ];
        name = "fragmentation";
        port = 9103;
      })
      (mkJob {
        appendNameToMetrics = true;
        name = "grafana";
        port = config.services.grafana.settings.server.http_port;
      })
      (mkJob {
        appendNameToMetrics = true;
        name = "prometheus";
        port = config.services.prometheus.port;
      })
      (mkJob {
        targets = [
          "LA-01-OVPN"
          "UK-01-OVPN"
          "Sweden-01-OVPN"
          "Amsterdam-01-OVPN"
          "Japan-01-OVPN"
          "France-01-OVPN"
          "Toronto-01-OVPN"
        ];
        name = "openvpn";
        port = 9176;
      })
      (mkJob {
        targets = [
          "Chicago-XDP-01"
          "India-XDP-02"
        ];
        interval = "5s";
        name = "xdp";
        port = 8080;
      })
      (mkJob {
        targets = [
          "shitzen-container"
          "LA-01-OVPN"
          "UK-01-OVPN"
          "Sweden-01-OVPN"
          "Amsterdam-01-OVPN"
          "Japan-01-OVPN"
          "France-01-OVPN"
          "Toronto-01-OVPN"
        ];
        name = "node";
        port = 9100;
      })
      (mkJob {
        targets = [
          "LA-01-OVPN"
          "UK-01-OVPN"
          "Sweden-01-OVPN"
          "Amsterdam-01-OVPN"
          "Japan-01-OVPN"
          "France-01-OVPN"
          "Toronto-01-OVPN"
        ];
        name = "smartctl";
        port = 9633;
      })
      (mkJob {
        targets = [
          "LA-01-OVPN"
          "UK-01-OVPN"
          "Sweden-01-OVPN"
          "Amsterdam-01-OVPN"
          "Japan-01-OVPN"
          "France-01-OVPN"
          "Toronto-01-OVPN"
        ];
        name = "zfs";
        port = 9134;
      })
    ];
    listenAddress = "0.0.0.0";
    port = 3001;
    webExternalUrl = "https://monitoring.ajaxvpn.org/prometheus/";
  };
}