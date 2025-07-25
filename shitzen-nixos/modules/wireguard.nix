{ config, lib, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.wireguard-tools ];
  networking.firewall.allowedUDPPorts = [ 51820 ];
  networking.wireguard = {
    enable = true;
    #interfaces.wg0 = {
    #  ips = [ "10.0.127.3/24" ];
    #  privateKeyFile = config.age.secrets.wireguard.path;
    #  peers = [
    #    #{
    #    #  publicKey = "lxnjP7Hz5k0eUoCvhxrgMnSx0/V7hUKIqqI5r2xZYTM=";
    #    #  allowedIPs = [ "0.0.0.0/0" ];
    #    #  endpoint = "74.208.44.130:51820";
    #    #  persistentKeepalive = 25;
    #    #}
    #  ];
    #};
  };
}