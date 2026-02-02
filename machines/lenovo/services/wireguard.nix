{ config
, pkgs
, ... }:

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
        allowedUDPPortRanges = [{
          from = 0;
          to = 65535;
        }];
      };
    };
    nat = {
      enable = false;
      externalInterface = "enp10s0";
      internalInterfaces = [ "wg0" ];
    };
    interfaces.wg0.useDHCP = false;
  };

  networking.wg-quick.interfaces.wg0 = {
    address = [ "10.0.10.3/32" "fd10::3/128" ];
    privateKeyFile = config.age.secrets.wireguard-home.path;
    dns = [
      "10.0.0.1"
      "10.0.0.2"
      "2601:406:8100:91d8::1"
      "2601:406:8100:91d8::146c"
    ];
    peers = [{
      allowedIPs = [
        #"0.0.0.0/0"
        #"::/0"
        "10.0.10.1/24"
        "10.0.0.0/24"
        "2601:406:8100:91D8::/64"
      ];
      endpoint = "76.112.236.206:51821";
      persistentKeepalive = 25;
      publicKey = "AU8rLt794hWpjsOK+zZjTcNcyzLIS5n6giiWS2rOcxk=";
    }];
  };
}