{ config
, pkgs
, ... }:

{
  networking.firewall = {
    allowedUDPPorts = [
      67 # DHCP Server
    ];
    trustedInterfaces = [ "enp1s0" ];
  };

  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = false;
    settings = {
      bind-interfaces = true;
      interface = [ "enp1s02" ];

      # Disable resolv.conf parsing, as we assign our own via DHCP.
      # Otherwise, it'd be what the ISP assigns, which we don't want :)
      no-resolv = true;
      # DNS Servers
      server = [
        "2601:406:8100:91D8::4"
        "2601:406:8100:91D8::6"
        "192.168.100.4"
        "192.168.100.6"
      ];

      dhcp-range = [
        # Comcast/Xfinity has always used 192.168.100.0/24 as a LAN subnet, and I'm just used to it now
        "192.168.100.10,192.168.100.254,2h"

        # TP-Link uses this, and I want a drop-in replacement, soo yeah.
        "2601:406:8100:91D8::10,2601:406:8100:91D8::ffff,64,2h"
      ];

      enable-ra = true;
      ra-param = "enp1s0,high";

      dhcp-option = [
        "option6:dns-server,[2606:4700:4700::1111],[2001:4860:4860::8888]"
      ];
    };
  };

  networking = {
    interfaces = {
      enp1s0 = {
        ipv4.addresses = [{
          address = "192.168.100.3";
          prefixLength = 24;
        }];
        ipv6.addresses = [{
          address = "2601:406:8100:91D8::3";
          prefixLength = 64;
        }];
      };
      enp0s21f0u1u4 = {
        ipv4.addresses = [{
          address = "192.168.100.2";
          prefixLength = 24;
        }];
        ipv6.addresses = [{
          address = "2601:406:8100:91D8::2";
          prefixLength = 64;
        }];
      };
    };
  };

  networking.nat = {
    enable = true;
    externalInterface = "enp0s21f0u1u4";
    internalInterfaces = [ "enp1s0" ];
  };
}