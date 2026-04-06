{ config
, lib
, pkgs
, ... }:

let
  cfg = config.router;
in {
  options.router = {
    enable = lib.mkEnableOption "Enable routing config with bridging";

    bridgeInterface = lib.mkOption {
      default = "br0";
      type = lib.types.str;
      description = "Virtual LAN interface for binding";
    };

    # To Modem
    wanInterface = lib.mkOption {
      type = lib.types.str;
      description = "Physical WAN interface";
    };

    # SFP Card
    lanInterfaces = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "Physical LAN interfaces that should be bridged";
    };

    lanSubnet = lib.mkOption {
      type = lib.types.str;
      default = "10.0.0";
      description = "Primary LAN IPv4 subnet";
    };

    lanSubnetV6 = lib.mkOption {
      type = lib.types.str;
      default = "fd3a:7c2b:9e11:1";
      description = "Primary LAN IPv6 subnet";
    };

    lanGateway = lib.mkOption {
      type = lib.types.str;
      default = "${cfg.lanSubnet}.1";
      description = "Router's LAN IP address";
    };

    dnsPrimaryIP = lib.mkOption {
      type = lib.types.str;
      default = "${cfg.lanSubnet}.1";
      description = "Primary DNS server IP";
    };

    dnsFallbackIP = lib.mkOption {
      type = lib.types.str;
      default = "1.1.1.1";
      description = "Secondary DNS server IP";
    };

    dnsPrimaryIPv6 = lib.mkOption {
      type = lib.types.str;
      default = "${cfg.lanSubnetV6}::1";
      description = "Primary DNS server IPv6";
    };

    dnsFallbackIPv6 = lib.mkOption {
      type = lib.types.str;
      default = "2606:4700:4700::1111";
      description = "Secondary DNS server IPv6";
    };
  };

  config = lib.mkIf cfg.enable {
    networking = {
      bridges.${cfg.bridgeInterface}.interfaces = cfg.lanInterfaces;
      dhcpcd = {
        enable = true;
        IPv6rs = false;
        allowInterfaces = [
          cfg.wanInterface
        ];
        denyInterfaces = [
          cfg.bridgeInterface
        ];
        extraConfig = ''
          interface ${cfg.wanInterface}
            noipv6rs
            ia_na 1
            ia_pd 2 ${cfg.bridgeInterface}/0
            rapid_commit
        '';
      };
      firewall.interfaces.${cfg.wanInterface} = {
        allowedUDPPorts = [
          546
        ];
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
              address = "${cfg.lanSubnetV6}::1";
              prefixLength = 64;
            }
          ];
        };
      };
      # Disable global DHCP, as we do it per-interface instead
      useDHCP = false;
    };
  };
}