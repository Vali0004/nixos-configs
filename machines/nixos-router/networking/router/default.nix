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
      default = "${cfg.lanSubnet}.1";
      description = "Router's LAN IP address";
    };

    dnsPrimaryIP = lib.mkOption {
      type = lib.types.str;
      default = "${cfg.lanSubnet}.2";
      description = "Primary DNS server IP";
    };

    dnsFallbackIP = lib.mkOption {
      type = lib.types.str;
      default = "75.75.75.75";
      description = "Secondary DNS server IP";
    };

    dnsPrimaryIPv6 = lib.mkOption {
      type = lib.types.str;
      default = "2601:406:8100:91d8:8eec:4bff:fe55:b2f1";
      description = "PrimaryDNS server IPv6";
    };

    dnsFallbackIPv6 = lib.mkOption {
      type = lib.types.str;
      default = "2001:558:FEED::1";
      description = "Secondary DNS server IPv6";
    };
  };

  config = {
    networking = {
      bridges.${cfg.bridgeInterface}.interfaces = cfg.lanInterfaces;
      dhcpcd = {
        enable = true;
        IPv6rs = true;
        allowInterfaces = [
          cfg.wanInterface
        ];
        denyInterfaces = [
          cfg.bridgeInterface
        ];
        extraConfig = ''
          interface ${cfg.wanInterface}
            ia_na 1
            #ia_pd 2 ${cfg.bridgeInterface}/0
        '';
      };
      interfaces = {
        # WAN, ISP uses DHCP, and DHCPv6/SLAAC for IP assignment, so enable it.
        ${cfg.wanInterface}.useDHCP = true;
        # Set the bridge to be a static IP, as it acts as the gateway
        ${cfg.bridgeInterface} = {
          ipv4.addresses = [{
            address = cfg.lanGateway;
            prefixLength = 24;
          }];
          ipv6.addresses = [
            {
              address = "2601:406:8100:91D8::";
              prefixLength = 64;
            }
            {
              address = "fe80::1";
              prefixLength = 64;
            }
          ];
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
