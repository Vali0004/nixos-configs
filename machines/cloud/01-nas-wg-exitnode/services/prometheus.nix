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
      openFirewall = false;
    };
    smartctl = {
      enable = true;
      devices = [
        "/dev/vda"
      ];
      openFirewall = false;
    };
    wireguard = {
      enable = true;
      interfaces = [ "wg0" ];
      openFirewall = false;
    };
    zfs = {
      enable = true;
      openFirewall = false;
    };
  };
}