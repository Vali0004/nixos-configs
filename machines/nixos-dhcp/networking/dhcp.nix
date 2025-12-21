{ config
, pkgs
, ... }:

let
  iface = "enp0s21f0u1u4";
in {
  networking.firewall = {
    allowedUDPPorts = [
      # DHCP
      67
      68
    ];
  };

  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = false;
    settings = {
      bind-interfaces = true;
      interface = [ iface ];

      # Disable resolv.conf parsing, as we assign our own via DHCP.
      # Otherwise, it'd be what the ISP assigns, which we don't want :)
      no-resolv = true;

      # DNS Servers
      server = [
        # For now, no pihole
        "2606:4700:4700::1111"
        "2001:4860:4860::8888"
        "1.1.1.1"
        "8.8.8.8"
      ];

      dhcp-range = [
        # Comcast/Xfinity has always used 10.0.0.0/24 as a LAN subnet, and I'm just used to it now
        "192.168.0.2,192.168.0.254,2h"

        # TP-Link uses this, and I want a drop-in replacement, soo yeah.
        "2001:db8:1::2,2001:db8:1::ffff,64,2h"
      ];
      dhcp-option = [
        "option6:dns-server,[2606:4700:4700::1111],[2001:4860:4860::8888]"
      ];

      enable-ra = true;
      ra-param = "${iface},high,60,1800";
    };
  };

  networking = {
    useDHCP = false;

    interfaces.${iface} = {
      # Public IPv4 from ISP
      useDHCP = true;

      # LAN IPv4
      ipv4.addresses = [{
        address = "192.168.0.1";
        prefixLength = 24;
      }];

      # LAN ULA IPv6
      ipv6.addresses = [{
        address = "2001:db8:1::1";
        prefixLength = 64;
      }];
    };

    nat = {
      enable = true;
      externalInterface = iface;
      internalInterfaces = [ ];
    };
  };
}