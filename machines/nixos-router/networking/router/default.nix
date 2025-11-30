{ config
, lib
, pkgs
, ... }:

let
  cfg = config.router;
in {
  options.router = {
    bridgeInterface = lib.mkOption {
      default = "br0";
      type = lib.types.str;
      description = "Virtual LAN interface for binding";
    };

    # Ethernet to DOCSIS modem
    wanInterface = lib.mkOption {
      type = lib.types.str;
      description = "Physical WAN interface (to DOCSIS modem)";
    };

    # Two SFP ports
    lanInterfaces = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "Physical LAN interfaces that should be bridged";
    };

    lanSubnet = lib.mkOption {
      type = lib.types.str;
      default = "10.0.0";
      description = "Primary LAN IPv4 subnet";
    };

    lanGateway = lib.mkOption {
      type = lib.types.str;
      default = "10.0.0.1";
      description = "Router's LAN IP address";
    };

    piholePrimaryIP = lib.mkOption {
      type = lib.types.str;
      default = "10.0.0.2";
      description = "Primary Pi-hole DNS server IP";
    };

    piholePrimaryIPv6 = lib.mkOption {
      type = lib.types.str;
      default = "2601:406:8100:91D8::2";
      description = "Primary Pi-hole DNS server IPv6";
    };

    piholeFallbackIP = lib.mkOption {
      type = lib.types.str;
      default = "10.0.0.3";
      description = "Secondary Pi-hole DNS server IP";
    };

    piholeFallbackIPv6 = lib.mkOption {
      type = lib.types.str;
      default = "2601:406:8100:91D8::3";
      description = "Secondary Pi-hole DNS server IPv6";
    };
  };

  config = {
    networking = {
      bridges.${cfg.bridgeInterface}.interfaces = cfg.lanInterfaces;
      interfaces = {
        # WAN, ISP uses DHCP, and DHCPv6/SLAAC for IP assignment, so enable it.
        ${cfg.wanInterface}.useDHCP = true;
        # Set the bridge to be a static IP, as it acts as the gateway
        ${cfg.bridgeInterface} = {
          ipv4.addresses = [{
            address = cfg.lanGateway;
            prefixLength = 24;
          }];
        };
      };
      # Disable global DHCP, as we do it per-interface instead
      useDHCP = false;
    };

    networking.nat = {
      enable = true;
      externalInterface = cfg.wanInterface;
      internalInterfaces = [ cfg.bridgeInterface ];
    };
  };
}
