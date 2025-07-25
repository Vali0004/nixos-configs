{ config, lib, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.agenix ];
  age.secrets = {
    wireguard-server = {
      file = ./../secrets/wireguard-server.age;
      owner = "wireguard";
      group = "wireguard";
    };
  };
}
