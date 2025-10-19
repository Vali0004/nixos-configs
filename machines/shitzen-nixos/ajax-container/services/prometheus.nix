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
          "Amsterdam-01-OVPN"
          "France-01-OVPN"
          "Japan-01-OVPN"
          "LA-01-OVPN"
          "Sweden-01-OVPN"
          "Toronto-01-OVPN"
          "UK-01-OVPN"
          "PRV-Germany-01"
          "AU-Syndey-01-OVH-WG"
          "BHS-02-OVH-WG"
          "LZ-AMS-02-OVH-WG"
          "RBX-01-OVH-WG"
          "UK-London-02-OVH-WG"
          "US-Atlana-GA-01-OVH-WG"
          "US-Chicago-IL-02-OVH-WG"
          "US-Chicago-IL-03-OVH-WG"
          "US-Dallas-TX-01-OVH-WG"
          "US-LosAngeles-CA-02-OVH-WG"
          "US-Miami-Florda-01-OVH-WG"
          "US-NYC-NY-01-OVH-WG"
          "US-Phoenix-AZ-01-OVH-WG"
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
          "Amsterdam-01-OVPN"
          "France-01-OVPN"
          "Japan-01-OVPN"
          "LA-01-OVPN"
          "Sweden-01-OVPN"
          "Toronto-01-OVPN"
          "UK-01-OVPN"
        ];
        name = "openvpn";
        port = 9176;
      })
      (mkJob {
        targets = [
          "India-XDP-01"
        ];
        interval = "5s";
        name = "xdp";
        port = 8080;
      })
      (mkJob {
        targets = [
          "shitzen-container"
          "Amsterdam-01-OVPN"
          "France-01-OVPN"
          "Japan-01-OVPN"
          "LA-01-OVPN"
          "Sweden-01-OVPN"
          "Toronto-01-OVPN"
          "UK-01-OVPN"
          "PRV-Germany-01"
          "AU-Syndey-01-OVH-WG"
          "BHS-02-OVH-WG"
          "LZ-AMS-02-OVH-WG"
          "RBX-01-OVH-WG"
          "UK-London-02-OVH-WG"
          "US-Atlana-GA-01-OVH-WG"
          "US-Chicago-IL-02-OVH-WG"
          "US-Chicago-IL-03-OVH-WG"
          "US-Dallas-TX-01-OVH-WG"
          "US-LosAngeles-CA-02-OVH-WG"
          "US-Miami-Florda-01-OVH-WG"
          "US-NYC-NY-01-OVH-WG"
          "US-Phoenix-AZ-01-OVH-WG"
        ];
        name = "node";
        port = 9100;
      })
      (mkJob {
        targets = [
          "Amsterdam-01-OVPN"
          "France-01-OVPN"
          "Japan-01-OVPN"
          "LA-01-OVPN"
          "Sweden-01-OVPN"
          "Toronto-01-OVPN"
          "UK-01-OVPN"
          "PRV-Germany-01"
          "AU-Syndey-01-OVH-WG"
          "BHS-02-OVH-WG"
          "LZ-AMS-02-OVH-WG"
          "RBX-01-OVH-WG"
          "UK-London-02-OVH-WG"
          "US-Atlana-GA-01-OVH-WG"
          "US-Chicago-IL-02-OVH-WG"
          "US-Chicago-IL-03-OVH-WG"
          "US-Dallas-TX-01-OVH-WG"
          "US-LosAngeles-CA-02-OVH-WG"
          "US-Miami-Florda-01-OVH-WG"
          "US-NYC-NY-01-OVH-WG"
          "US-Phoenix-AZ-01-OVH-WG"
        ];
        name = "smartctl";
        port = 9633;
      })
      (mkJob {
        targets = [
          "Amsterdam-01-OVPN"
          "France-01-OVPN"
          "Japan-01-OVPN"
          "LA-01-OVPN"
          "Sweden-01-OVPN"
          "Toronto-01-OVPN"
          "UK-01-OVPN"
          "PRV-Germany-01"
          "AU-Syndey-01-OVH-WG"
          "BHS-02-OVH-WG"
          "LZ-AMS-02-OVH-WG"
          "RBX-01-OVH-WG"
          "UK-London-02-OVH-WG"
          "US-Atlana-GA-01-OVH-WG"
          "US-Chicago-IL-02-OVH-WG"
          "US-Chicago-IL-03-OVH-WG"
          "US-Dallas-TX-01-OVH-WG"
          "US-LosAngeles-CA-02-OVH-WG"
          "US-Miami-Florda-01-OVH-WG"
          "US-NYC-NY-01-OVH-WG"
          "US-Phoenix-AZ-01-OVH-WG"
        ];
        interval = "5s";
        name = "wireguard";
        port = 9586;
      })
      (mkJob {
        targets = [
          "Amsterdam-01-OVPN"
          "France-01-OVPN"
          "Japan-01-OVPN"
          "LA-01-OVPN"
          "Sweden-01-OVPN"
          "Toronto-01-OVPN"
          "UK-01-OVPN"
          "PRV-Germany-01"
          "AU-Syndey-01-OVH-WG"
          "BHS-02-OVH-WG"
          "LZ-AMS-02-OVH-WG"
          "RBX-01-OVH-WG"
          "UK-London-02-OVH-WG"
          "US-Atlana-GA-01-OVH-WG"
          "US-Chicago-IL-02-OVH-WG"
          "US-Chicago-IL-03-OVH-WG"
          "US-Dallas-TX-01-OVH-WG"
          "US-LosAngeles-CA-02-OVH-WG"
          "US-Miami-Florda-01-OVH-WG"
          "US-NYC-NY-01-OVH-WG"
          "US-Phoenix-AZ-01-OVH-WG"
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