{ config, lib, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.wireguard-tools ];
  networking.firewall.allowedUDPPorts = [ 51820 ];
  networking.wireguard = {
    enable = true;
    interfaces.wg0 = {
      ips = [ "10.127.0.3/24" ];
      privateKeyFile = config.age.secrets.wireguard.path;
      peers = [
        {
          publicKey = "EjPutSj3y/DuPfz4F0W3PYz09Rk+XObW2Wh4W5cDrwA=";
          allowedIPs = [ "10.127.0.1/32" ];
          endpoint = "74.208.44.130:51820";
          persistentKeepalive = 25;
        }
      ];
    };
  };
}