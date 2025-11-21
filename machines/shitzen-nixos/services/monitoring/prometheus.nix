{ config
, ... }:

let
  mkJob = import ../../modules/mkprometheus.nix;
in {
  networking.firewall.allowedTCPPorts = [
    config.services.prometheus.exporters.node.port
  ];

  services.prometheus = {
    enable = true;
    enableReload = true;
    scrapeConfigs = [
      (mkJob {
        name = "fragmentation";
        targets = [
          "shitzen-nixos"
          "router-vps"
          "lenovo"
        ];
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
        appendNameToMetrics = true;
        name = "xdp";
        interval = "1s";
        port = 9192;
        targets = [
          "router-vps"
        ];
      })
      (mkJob {
        name = "prowlarr";
        port = config.services.prometheus.exporters.exportarr-prowlarr.port;
      })
      (mkJob {
        targets = [
          "shitzen-nixos"
          "router-vps"
          "lenovo"
        ];
        name = "node";
        port = config.services.prometheus.exporters.node.port;
      })
      (mkJob {
        name = "radarr";
        port = config.services.prometheus.exporters.exportarr-radarr.port;
      })
      (mkJob {
        name = "rtorrent";
        port = config.services.prometheus.exporters.smartctl.port;
      })
      (mkJob {
        targets = [
          "shitzen-nixos"
          "router-vps"
          "lenovo"
        ];
        name = "smartctl";
        port = config.services.prometheus.exporters.smartctl.port;
      })
      (mkJob {
        name = "sonarr";
        port = config.services.prometheus.exporters.exportarr-sonarr.port;
      })
      (mkJob {
        name = "wireguard";
        interval = "1s";
        port = config.services.prometheus.exporters.wireguard.port;
      })
      (mkJob {
        targets = [
          "shitzen-nixos"
          "lenovo"
          "router-vps"
        ];
        name = "zfs";
        port = config.services.prometheus.exporters.zfs.port;
      })
    ];
    exporters = {
      exportarr-prowlarr = {
        apiKeyFile = config.age.secrets.prowlarr-api.path;
        enable = true;
        environment.LOG_LEVEL = "warn";
        port = 9708;
        url = "https://prowlarr.fuckk.lol";
      };
      exportarr-sonarr = {
        apiKeyFile = config.age.secrets.sonarr-api.path;
        enable = true;
        environment.LOG_LEVEL = "warn";
        port = 9709;
        url = "https://sonarr.fuckk.lol";
      };
      exportarr-radarr = {
        apiKeyFile = config.age.secrets.radarr-api.path;
        enable = true;
        environment.LOG_LEVEL = "warn";
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