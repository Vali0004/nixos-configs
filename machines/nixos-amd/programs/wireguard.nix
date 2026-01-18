{ config
, ... }:

{
  networking.wg-quick.interfaces.wg0 = {
    address = [ "10.5.5.2/32" ];
    privateKeyFile = config.age.secrets.wireguard-private-yuts.path;
    peers = [{
      allowedIPs = [ "10.5.5.0/24" "10.0.0.0/24" ];
      endpoint = "24.65.132.48:51820";
      persistentKeepalive = 25;
      publicKey = "yktwBksHr1/nK5vgqn82aZdm3oBA291zEOktHrt4Nic=";
    }];
  };
}