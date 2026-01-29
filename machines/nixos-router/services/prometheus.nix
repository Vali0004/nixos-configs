{ config
, ... }:

let
  cfg = config.services.prometheus.exporters;
in {
  networking.firewall.interfaces.${config.router.bridgeInterface}.allowedTCPPorts = [
    cfg.node.port
    cfg.smartctl.port
    cfg.zfs.port
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
        "zfs"
      ];
      openFirewall = false;
    };
    smartctl = {
      enable = true;
      devices = [
        "/dev/mmcblk0"
      ];
      openFirewall = false;
    };
    zfs = {
      enable = true;
      openFirewall = false;
    };
  };
}