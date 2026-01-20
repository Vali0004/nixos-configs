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
    smartctl = {
      enable = true;
      devices = [
        "/dev/mmcblk0"
      ];
      openFirewall = true;
    };
    zfs = {
      enable = true;
      openFirewall = true;
    };
  };
}