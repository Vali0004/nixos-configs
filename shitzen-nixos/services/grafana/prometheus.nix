{ config, inputs, lib, pkgs, ... }:

let
  mkJob = import ./../../modules/mkprometheus.nix;
in {
  networking.firewall.allowedTCPPorts = [
    9100 # Node Exporter
  ];

  services.prometheus = {
    enable = true;
    enableReload = true;
    scrapeConfigs = [
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
          "shitzen-nixos"
          "router-vps"
        ];
        name = "node";
        port = 9100;
      })
      (mkJob {
        name = "smartctl";
        port = 9633;
      })
      (mkJob {
        name = "wireguard";
        interval = "1s";
        port = 9586;
      })
      (mkJob {
        name = "zfs";
        port = 9134;
      })
    ];
    exporters = {
      # TODO: Needs API keys in a file
      #exportarr-sonarr.enable = true;
      #exportarr-radarr.enable = true;
      #exportarr-prowlarr.enable = true;
      node = {
        enable = true;
        enabledCollectors = [
          "cpu"
          "filesystem"
          "interrupts"
          "loadavg"
          "meminfo"
          "netstat"
          "systemd"
        ];
      };
      smartctl = {
        enable = true;
        devices = [
          "/dev/sda"
          "/dev/sdb"
          "/dev/sdc"
          "/dev/sdd"
        ];
      };
      wireguard = {
        enable = true;
        interfaces = [ "wg0" ];
      };
      zfs.enable = true;
    };
    listenAddress = "${config.networking.hostName}";
    port = 3400;
    webExternalUrl = "https://monitoring.fuckk.lol/prometheus/";
  };
}