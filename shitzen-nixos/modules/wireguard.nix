{ config, lib, pkgs, ... }:

let
  ipt = "${pkgs.iptables}/bin/iptables";
in {
  environment.systemPackages = [ pkgs.wireguard-tools ];

  networking.firewall.allowedUDPPorts = [ 51820 ];

  networking.wireguard = {
    useNetworkd = true;
    enable = true;
    interfaces.wg0 = {
      allowedIPsAsRoutes = false;
      ips = [ "10.127.0.3/32" ];
      privateKeyFile = config.age.secrets.wireguard.path;
      peers = [
        {
          allowedIPs = [ "0.0.0.0/0" ];
          endpoint = "74.208.44.130:51820";
          persistentKeepalive = 5;
          publicKey = "EjPutSj3y/DuPfz4F0W3PYz09Rk+XObW2Wh4W5cDrwA=";
        }
      ];
    };
  };

  networking.nftables = {
    enable = true;
    ruleset = ''
      table inet mangle {
        chain output {
          type route hook output priority mangle; policy accept;

          meta skuid 981 meta l4proto udp mark set 1
        }
      }

      table ip nat {
        chain postrouting {
          type nat hook postrouting priority srcnat; policy accept;

          oifname "wg0" masquerade
        }
      }
    '';
  };

  systemd.network.networks."30-wg0" = {
    matchConfig.Name = "wg0";
    address = [ "10.127.0.3/24" ];
    routes = [{
      routeConfig = {
        Gateway = "10.127.0.1";
        Destination = "0.0.0.0/0";
        Table = 100;
      };
    }];
    routingPolicyRules = [{
      routingPolicyRuleConfig = {
        FirewallMark = 1;
        Table = 100;
        Priority = 100;
      };
    }];
  };
}