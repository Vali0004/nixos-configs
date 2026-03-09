{ config
, ... }:

{
  # Techinally, pihole has a option, but I don't trust it fully.
  networking = {
    firewall.interfaces.${config.router.bridgeInterface}.allowedUDPPorts = [
      67 # DHCP Server
      547 # DHCPv6 Server
    ];
    # Use pihole's internal DNS instead.
    nameservers = [
      "127.0.0.1"
      "::1"
    ];
    # Tell resolv.conf from upstream to kick rocks
    dhcpcd = {
      enable = true;
      extraConfig = ''
        nohook resolv.conf
      '';
    };
  };

  services.dnsmasq = {
    enable = true;
    settings = {
      bind-interfaces = true;
      interface = [ config.router.bridgeInterface ];

      # Disable resolv.conf parsing, as we assign our own via DHCP.
      # Otherwise, it'd be what the ISP assigns, which we don't want :)
      no-resolv = true;

      dhcp-authoritative = true;
      dhcp-host = [
        "8C:EC:4B:55:B2:F1,set:nixos-shitclient,${config.router.lanSubnet}.2,nixos-shitclient,infinite"
        "6C:2B:59:75:AA:B7,set:nixos-hass,${config.router.lanSubnet}.3,nixos-hass,infinite"
        "F0:12:04:60:F8:9F,set:nixos-shitzen,${config.router.lanSubnet}.4,nixos-shitzen,infinite"
        "48:DA:35:6F:39:D0,set:kvm-39d0,${config.router.lanSubnet}.5,kvm-39d0,infinite"
        "78:20:51:DA:33:F6,set:decoMeshXE75,${config.router.lanSubnet}.6,decoMeshXE75,infinite"
        "78:20:51:DA:36:2A,set:deco-XE75,${config.router.lanSubnet}.7,deco-XE75,infinite"
        "78:20:51:DA:36:02,set:deco-XE75,${config.router.lanSubnet}.8,deco-XE75,infinite"
        "78:20:51:DA:33:F5,set:deco-XE75,${config.router.lanSubnet}.9,deco-XE75,infinite"
        "E0:D3:62:D1:34:BE,set:deco-XE70Pro,${config.router.lanSubnet}.10,deco-XE70Pro,infinite"
        "C0:35:32:5F:CC:23,set:lenovo,${config.router.lanSubnet}.31,lenovo,infinite"
        "10:FF:E0:35:08:FB,set:nixos-amd,${config.router.lanSubnet}.189,nixos-amd,infinite"
        "d0:46:0c:7d:bf:c4,set:worklaptop,${config.router.lanSubnet}.50,US-ANH-L-A12597,infinite"
      ];
      dhcp-range = [
        # Comcast/Xfinity has always used 10.0.0.0/24 as a LAN subnet, and I'm just used to it now
        "${config.router.lanSubnet}.2,${config.router.lanSubnet}.254,2h"
        #"${config.router.lanSubnetV6}::1,${config.router.lanSubnetV6}::ffff,64,2h"
        # Disable DHCPv6
        "::,constructor:${config.router.bridgeInterface},ra-stateless,ra-names,64,2h"
      ];
      dhcp-option = [
        "option:dns-server,${config.router.dnsPrimaryIP},${config.router.dnsFallbackIP}"
        "option6:dns-server,[${config.router.dnsPrimaryIPv6}],[${config.router.dnsFallbackIPv6}]"
      ];
      dhcp-ignore-names = [ "tag:worklaptop" ];

      enable-ra = true;
      ra-param = [ "br0,1800" ]; # M=1800, O=0

      port = 0; # Disable DNS fully
    };
  };
}