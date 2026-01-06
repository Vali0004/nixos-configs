{ config
, ... }:

{
  boot.kernel.sysctl = {
    # IPv4 Forwarding
    "net.ipv4.ip_forward" = true;
    "net.ipv4.tcp_syncookies" = true;

    # IPv6 forwarding
    "net.ipv6.conf.all.forwarding" = true;

    # By default, do not automatically configure any IPv6 addresses.
    "net.ipv6.conf.all.accept_ra" = 0;
    "net.ipv6.conf.all.autoconf" = 0;
    "net.ipv6.conf.all.use_tempaddr" = 0;
    "net.ipv4.conf.all.rp_filter" = 0;

    "net.ipv4.conf.default.rp_filter" = 0;

    # On WAN, allow IPv6 autoconfiguration and tempory address use.
    "net.ipv6.conf.${config.router.wanInterface}.accept_ra" = 2;
    "net.ipv6.conf.${config.router.wanInterface}.autoconf" = 1;
    "net.ipv4.conf.${config.router.wanInterface}.rp_filter" = 0;
    "net.ipv4.conf.${config.router.bridgeInterface}.rp_filter" = 0;
  };
}