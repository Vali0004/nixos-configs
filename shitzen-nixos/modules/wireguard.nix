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
          publicKey = "EjPutSj3y/DuPfz4F0W3PYz09Rk+XObW2Wh4W5cDrwA=";
          allowedIPs = [ "0.0.0.0/0" ];
          endpoint = "74.208.44.130:51820";
          persistentKeepalive = 25;
        }
      ];
    };
  };

  systemd.network.networks."30-wg0" = {
    matchConfig.Name = "wg0";
    address = [ "10.127.0.3/24" ];
    routingPolicyRules = [{
      routingPolicyRuleConfig = {
        FirewallMark = 1;
        Table = 100;
        Priority = 100;
      };
    }];
  };
}