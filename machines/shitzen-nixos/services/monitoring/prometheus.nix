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
      #(lib.mkPrometheusJob {
      #  name = "fragmentation";
      #  targets = [
      #    "nixos-hass"
      #    "nixos-shitclient"
      #    "shitzen-nixos"
      #    "router-vps"
      #    "lenovo"
      #  ];
      #  port = 9103;
      #})
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
          "nixos-hass"
          "nixos-shitclient"
          "shitzen-nixos"
          "router-vps"
          "lenovo"
        ];
        name = "node";
        port = config.services.prometheus.exporters.node.port;
      })
      (lib.mkPrometheusJob {
        name = "radarr";
        port = config.services.prometheus.exporters.exportarr-radarr.port;
      })
      (lib.mkPrometheusJob {
        name = "rtorrent";
        port = config.services.prometheus.exporters.smartctl.port;
      })
      (lib.mkPrometheusJob {
        targets = [
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