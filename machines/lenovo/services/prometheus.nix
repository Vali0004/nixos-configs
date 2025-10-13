{ config, inputs, lib, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [
    9100 # Node Exporter
    9134 # ZFS Exporter
    9633 # SmartCTL Exporter
  ];

  services.prometheus.exporters = {
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
      ];
      port = 9100;
    };
    smartctl = {
      enable = true;
      devices = [
        "/dev/sda"
      ];
    };
    zfs.enable = true;
  };
}