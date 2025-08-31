{ config, lib, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.wireguard-tools ];

  networking = {
    networkmanager.unmanaged = [
      "interface-name:wg0"
    ];
    firewall = {
      allowPing = true;
      allowedUDPPorts = [ 51820 ];
      checkReversePath = false;
      interfaces.wg0 = {
        allowedTCPPortRanges = [{
          from = 0;
          to = 65535;
        }];
      };
    };
    nat = {
      enable = false;
      externalInterface = "eth0";
      internalInterfaces = [ "wg0" ];
    };
    interfaces.wg0.useDHCP = false;
  };

  networking.wg-quick = {
    interfaces = {
      wg0 = {
        address = [ "10.127.0.3/32" ];
        privateKeyFile = config.age.secrets.wireguard.path;
        peers = [{
          allowedIPs = [ "0.0.0.0/0" "::/0" ];
          endpoint = "74.208.44.130:51820";
          persistentKeepalive = 25;
          publicKey = "EjPutSj3y/DuPfz4F0W3PYz09Rk+XObW2Wh4W5cDrwA=";
        }];
      };
    };
  };
}
