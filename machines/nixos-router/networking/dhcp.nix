{ config
, pkgs
, ... }:

{
  networking.firewall = {
    allowedUDPPorts = [
      67 # DHCP Server
    ];
    # This may be needed at some point, who knows.
    #trustedInterfaces = [ config.router.wanInterface ];
  };

  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = false;
    settings = {
      bind-interfaces = true;
      interface = [ config.router.bridgeInterface ];

      # Disable resolv.conf parsing, as we assign our own via DHCP.
      # Otherwise, it'd be what the ISP assigns, which we don't want :)
      no-resolv = true;

      # DNS Servers
      server = [
        config.router.dnsPrimaryIPv6
        config.router.dnsFallbackIPv6
        config.router.dnsPrimaryIP
        config.router.dnsFallbackIP
      ];

      dhcp-host = [
        "8C:EC:4B:55:B2:F1,set:nixos-hass,${config.router.lanSubnet}.2,nixos-shitclient,infinite"
        "6C:2B:59:75:AA:B7,set:nixos-hass,${config.router.lanSubnet}.3,nixos-hass,infinite"
        "F0:12:04:60:F8:9F,set:nixos-shitzen,${config.router.lanSubnet}.4,nixos-shitzen,infinite"
        "48:DA:35:6F:39:D0,set:kvm-39d0,${config.router.lanSubnet}.5,kvm-39d0,infinite"
        "78:20:51:DA:33:F6,set:decoMeshXE75,${config.router.lanSubnet}.6,decoMeshXE75,infinite"
        "78:20:51:DA:36:2A,set:deco-XE75,${config.router.lanSubnet}.7,deco-XE75,infinite"
        "78:20:51:DA:36:02,set:deco-XE75,${config.router.lanSubnet}.8,deco-XE75,infinite"
        "78:20:51:DA:36:F5,set:deco-XE75,${config.router.lanSubnet}.9,deco-XE75,infinite"
        "E0:D3:62:D1:34:BE,set:deco-XE70Pro,${config.router.lanSubnet}.10,deco-XE70Pro,infinite"
        "C0:35:32:5F:CC:23,set:lenovo,${config.router.lanSubnet}.31,lenovo,infinite"
        "10:FF:E0:35:08:FB,set:nixos-amd,${config.router.lanSubnet}.189,nixos-amd,infinite"
      ];

      dhcp-range = [
        # Comcast/Xfinity has always used 10.0.0.0/24 as a LAN subnet, and I'm just used to it now
        "${config.router.lanSubnet}.2,${config.router.lanSubnet}.254,2h"
        "2601:406:8100:91D8::1,2601:406:8100:91D8::ffff,64,2h"
        "::,constructor:${config.router.bridgeInterface},ra-stateless,2h"
      ];

      enable-ra = true;
    };
  };
}