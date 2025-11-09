{
  networking.firewall.allowedTCPPorts = [
    9100 # Node Exporter
    9134 # ZFS
    9586 # WireGuard
    9633 # SmartCTL
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
      port = 9100;
    };
    smartctl = {
      enable = true;
      devices = [
        "/dev/vda"
      ];
    };
    wireguard = {
      enable = true;
      interfaces = [ "wg0" ];
    };
    zfs.enable = true;
  };
}