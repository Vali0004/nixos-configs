{ config, lib, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.wireguard-tools ];

  networking = {
    networkmanager.unmanaged = [ "interface-name:wg0" ];
    firewall = {
      allowedUDPPorts = [ 51820 51821 ];
      checkReversePath = false;
      interfaces.wg0 = {
        allowedTCPPortRanges = [{
          from = 0;
          to = 65535;
        }];
      };
    };
    nat = {
      enable = true;
      externalInterface = "wg0";
      internalInterfaces = [ "wg1" ];
    };
    interfaces.wg0.useDHCP = false;
    interfaces.wg1.useDHCP = false;
  };

  networking.wg-quick = {
    interfaces = {
      wg0 = {
        address = [ "10.127.0.3/32" ];
        privateKeyFile = config.age.secrets.wireguard.path;
        peers = [{
          allowedIPs = [ "0.0.0.0/0" ];
          endpoint = "74.208.44.130:51820";
          persistentKeepalive = 25;
          publicKey = "EjPutSj3y/DuPfz4F0W3PYz09Rk+XObW2Wh4W5cDrwA=";
        }];
      };
      wg1 = {
        address = [ "10.100.0.1/24" ];
        listenPort = 51821;
        privateKeyFile = config.age.secrets.wireguard-down.path;
        peers = [{
          allowedIPs = [ "10.100.0.2/32" ];
          publicKey = "JlHHaH807y8/qcHlgm0RBzrd1/NLkgzvQJCiqTlK6mU=";
        }];
      };
    };
  };
}