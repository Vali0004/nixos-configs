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
    scrapeConfigs = [
      (mkJob {
        targets = [
          "shitzen-nixos"
          "France-1"
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
          "France-1"
        ];
        name = "openvpn";
        port = 9176;
      })
      (mkJob {
        name = "prowlarr";
        port = 9708;
      })
      (mkJob {
        targets = [
          "shitzen-nixos"
          "router-vps"
          "lenovo"
          "LA-1"
          "UK-1"
          "Sweden-1"
          "Amsterdam-1"
          "Japan-1"
          "France-1"
          "Toronto-1"
        ];
        name = "node";
        port = 9100;
      })
      (mkJob {
        name = "radarr";
        port = 9710;
      })
      (mkJob {
        name = "rtorrent";
        port = 9135;
      })
      (mkJob {
        targets = [
          "shitzen-nixos"
          "lenovo"
          "France-1"
        ];
        name = "smartctl";
        port = 9633;
      })
      (mkJob {
        name = "sonarr";
        port = 9709;
      })
      (mkJob {
        name = "wireguard";
        interval = "1s";
        port = 9586;
      })
      (mkJob {
        targets = [
          "shitzen-nixos"
          "lenovo"
          "France-1"
        ];
        name = "zfs";
        port = 9134;
      })
    ];
    exporters = {
      exportarr-prowlarr = {
        apiKeyFile = config.age.secrets.prowlarr-api.path;
        enable = true;
        port = 9708;
        url = "https://prowlarr.fuckk.lol";
      };
      exportarr-sonarr = {
        apiKeyFile = config.age.secrets.sonarr-api.path;
        enable = true;
        port = 9709;
        url = "https://sonarr.fuckk.lol";
      };
      exportarr-radarr = {
        apiKeyFile = config.age.secrets.radarr-api.path;
        enable = true;
        port = 9710;
        url = "https://radarr.fuckk.lol";
      };
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
          "systemd.enable-start-time-metrics"
          "zfs"
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
    listenAddress = "0.0.0.0";
    port = 3400;
    webExternalUrl = "https://monitoring.fuckk.lol/prometheus/";
  };
}