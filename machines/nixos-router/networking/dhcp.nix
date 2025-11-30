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
        config.router.piholePrimaryIPv6
        config.router.piholeFallbackIPv6
        config.router.piholePrimaryIP
        config.router.piholeFallbackIP
      ];

      dhcp-range = [
        # Comcast/Xfinity has always used 10.0.0.0/24 as a LAN subnet, and I'm just used to it now
        "${config.router.lanSubnet}.10,${config.router.lanSubnet}.254,2h"

        # TP-Link uses this, and I want a drop-in replacement, soo yeah.
        "2601:406:8100:91D8::10,2601:406:8100:91D8::ffff,64,2h"
      ];

      enable-ra = true;
      ra-param = "${config.router.bridgeInterface},high";

      dhcp-option = [
        "option6:dns-server,[2606:4700:4700::1111],[2001:4860:4860::8888]"
      ];
    };
  };
}