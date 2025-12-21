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

    # On WAN, allow IPv6 autoconfiguration and tempory address use.
    "net.ipv6.conf.enp0s21f0u1u4.accept_ra" = 2;
    "net.ipv6.conf.enp0s21f0u1u4.autoconf" = 1;
  };
}