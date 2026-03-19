{ config
, lib
, ... }:

{
  networking.firewall.allowedTCPPorts = [
    config.services.prometheus.exporters.node.port
    config.services.prometheus.port
  ];

  services.prometheus = {
    enable = true;
    enableReload = true;
    scrapeConfigs = [
      (lib.mkPrometheusJob {
        name = "bind";
        targets = [
          "nixos-router"
        ];
        port = config.services.prometheus.exporters.bind.port;
        interval = "15s";
      })
      (lib.mkPrometheusJob {
        name = "fragmentation";
        targets = [
          "lenovo"
          "nixos-hass"
          "nixos-router"
          "nixos-shitclient"
          "shitzen-nixos"
          "router-vps"
        ];
        port = 9103;
      })
      (lib.mkPrometheusJob {
        appendNameToMetrics = true;
        name = "grafana";
        port = config.services.grafana.settings.server.http_port;
      })
      (lib.mkPrometheusJob {
        appendNameToMetrics = true;
        name = "prometheus";
        port = config.services.prometheus.port;
      })
      (lib.mkPrometheusJob {
        name = "prowlarr";
        port = config.services.prometheus.exporters.exportarr-prowlarr.port;
      })
      (lib.mkPrometheusJob {
        targets = [
          "nixos-router"
        ];
        name = "docsis";
        port = 9712;
        interval = "120s";
      })
      (lib.mkPrometheusJob {
        targets = [
          "nixos-router"
          "nixos-hass"
          "nixos-shitclient"
          "shitzen-nixos"
          "router-vps"
          "lenovo"
        ];
        name = "node";
        port = config.services.prometheus.exporters.node.port;
        interval = "30s";
      })
      (lib.mkPrometheusJob {
        name = "radarr";
        port = config.services.prometheus.exporters.exportarr-radarr.port;
      })
      (lib.mkPrometheusJob {
        name = "rtorrent";
        port = 9135;
      })
      (lib.mkPrometheusJob {
        name = "rtorrent-private";
        port = 9136;
      })
      (lib.mkPrometheusJob {
        targets = [
          "nixos-router"
          "nixos-hass"
          "nixos-shitclient"
          "shitzen-nixos"
          "router-vps"
          "lenovo"
        ];
        name = "smartctl";
        port = config.services.prometheus.exporters.smartctl.port;
      })
      (lib.mkPrometheusJob {
        name = "sonarr";
        port = config.services.prometheus.exporters.exportarr-sonarr.port;
      })
      (lib.mkPrometheusJob {
        name = "wireguard";
        interval = "1s";
        port = config.services.prometheus.exporters.wireguard.port;
      })
      (lib.mkPrometheusJob {
        targets = [
          "nixos-router"
          "nixos-hass"
          "nixos-shitclient"
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
        url = "http://shitzen-nixos:${toString config.services.prowlarr.settings.server.port}";
      };
      exportarr-sonarr = {
        apiKeyFile = config.age.secrets.sonarr-api.path;
        enable = true;
        environment.LOG_LEVEL = "warn";
        port = 9709;
        url = "http://shitzen-nixos:${toString config.services.sonarr.settings.server.port}";
      };
      exportarr-radarr = {
        apiKeyFile = config.age.secrets.radarr-api.path;
        enable = true;
        environment.LOG_LEVEL = "warn";
        port = 9710;
        url = "http://shitzen-nixos:${toString config.services.radarr.settings.server.port}";
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
    webExternalUrl = "https://monitoring.lab004.dev/prometheus/";
  };
}