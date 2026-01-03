{
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
      openFirewall = true;
    };
    zfs = {
      enable = true;
      openFirewall = true;
    };
  };
}