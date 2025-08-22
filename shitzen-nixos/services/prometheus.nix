{ config, inputs, lib, pkgs, ... }:

let
  mkJob = import ./../modules/mkprometheus.nix;
in {
  services.prometheus = {
    enable = true;
    scrapeConfigs = [
      (mkJob {
        appendNameToMetrics = true;
        name = "grafana";
        port = 3003;
      })
      (mkJob {
        appendNameToMetrics = true;
        name = "prometheus";
        port = 3400;
      })
      (mkJob {
        name = "smartctl";
        port = 9633;
      })
      (mkJob {
        name = "wireguard";
        interval = "1s";
        port = 9586;
        label = "";
      })
      (mkJob {
        name = "zfs";
        port = 9134;
        label = "";
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
    listenAddress = "127.0.0.1";
    port = 3400;
    webExternalUrl = "https://monitoring.fuckk.lol/prometheus/";
  };
}