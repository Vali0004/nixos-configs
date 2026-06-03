{ config
, ... }:

{
  boot.kernel.sysctl = {
    # IPv4 Forwarding
    "net.ipv4.ip_forward" = true;

    # Basic TCP tuning
    "net.ipv4.tcp_syncookies" = true;
    "net.ipv4.tcp_timestamps" = true;
    "net.ipv4.tcp_sack" = true;
    "net.ipv4.tcp_fack" = true;

    # IPv6 forwarding
    "net.ipv6.conf.all.forwarding" = true;

    # Set the default SQM as CAKE
    "net.core.default_qdisc" = "cake";

    # Read/Write Memory Max Tuning
    "net.core.rmem_max" = 134217728;
    "net.core.wmem_max" = 134217728;

    # By default, do not automatically configure any IPv6 addresses.
    "net.ipv6.conf.all.accept_ra" = 0;
    "net.ipv6.conf.all.autoconf" = 1;
    "net.ipv6.conf.all.use_tempaddr" = 0;
    "net.ipv4.conf.all.rp_filter" = 0;

    "net.ipv4.conf.default.rp_filter" = 0;

    # TCP Read/Write Memory Max Tuning
    "net.ipv4.tcp_rmem" = "4096 87380 134217728";
    "net.ipv4.tcp_wmem" = "4096 65536 134217728";

    # Congestion control algorithim
    "net.ipv4.tcp_congestion_control" = "bbr";

    # On WAN, allow IPv6 autoconfiguration and tempory address use.
    "net.ipv6.conf.${config.router.wanInterface}.accept_ra" = 2;
    "net.ipv6.conf.${config.router.wanInterface}.autoconf" = 1;
    "net.ipv4.conf.${config.router.wanInterface}.rp_filter" = 0;
    "net.ipv4.conf.${config.router.bridgeInterface}.rp_filter" = 0;
  };
}