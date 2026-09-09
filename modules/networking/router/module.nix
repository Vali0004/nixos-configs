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

    # To Fallback Modem (Verizon 5G box: CGNAT'd, double-NAT, no inbound, no PD)
    wan2Interface = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "2nd Physical WAN interface, used as a fallback uplink";
    };

    wanMetric = lib.mkOption {
      type = lib.types.int;
      default = 100;
      description = "Route metric for the primary WAN's default route while healthy";
    };

    wanDemotedMetric = lib.mkOption {
      type = lib.types.int;
      default = 9000;
      description = "Route metric the primary WAN is demoted to when it fails health checks";
    };

    wan2Metric = lib.mkOption {
      type = lib.types.int;
      default = 1000;
      description = "Route metric for the fallback WAN's default route";
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
        ] ++ lib.optional (cfg.wan2Interface != null) cfg.wan2Interface;
        denyInterfaces = [
          cfg.bridgeInterface
        ];
        extraConfig = ''
          interface ${cfg.wanInterface}
            noipv6rs
            ia_na 1
            ia_pd 2 ${cfg.bridgeInterface}/0
            rapid_commit
            metric ${toString cfg.wanMetric}
        '' + lib.optionalString (cfg.wan2Interface != null) ''

          # Fallback uplink. It is a consumer CGNAT gateway: it hands us a
          # RFC1918 lease and NATs us again. Take v4 only, at a worse metric,
          # and never let it touch DNS or v6 - v6 stays exclusive to wan1,
          # since there is no prefix to delegate behind that box.
          interface ${cfg.wan2Interface}
            ipv4only
            noipv6
            noipv6rs
            nohook resolv.conf
            metric ${toString cfg.wan2Metric}
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
      } // lib.optionalAttrs (cfg.wan2Interface != null) {
        ${cfg.wan2Interface}.useDHCP = true;
      } // {
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