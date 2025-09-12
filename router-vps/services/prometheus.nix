{ config, inputs, lib, pkgs, ... }:

let
  mkJob = import ./../modules/mkprometheus.nix;
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
        name = "prometheus";
        port = 3400;
      })
      (mkJob {
        name = "node";
        port = 9100;
      })
    ];
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
      ];
      port = 9100;
    };
    listenAddress = "127.0.0.1";
    port = 3400;
    webExternalUrl = "https://monitoring.fuckk.lol/prometheus/";
  };
}