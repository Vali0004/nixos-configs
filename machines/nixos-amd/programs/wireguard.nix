{ config
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
    address = [ "10.5.5.2/32" ];
    privateKeyFile = config.age.secrets.wireguard-private-yutsu.path;
    peers = [{
      allowedIPs = [ "10.5.5.0/24" "10.0.0.0/24" ];
      endpoint = "24.65.132.48:51820";
      persistentKeepalive = 25;
      publicKey = "yktwBksHr1/nK5vgqn82aZdm3oBA291zEOktHrt4Nic=";
    }];
  };
}