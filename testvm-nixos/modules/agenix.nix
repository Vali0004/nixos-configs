{ config, lib, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.agenix ];
  age.secrets = {
    shadowsocks = {
      file = ./../../secrets/shadowsocks.age;
      owner = "root";
      group = "root";
    };
    wireguard-server = {
      file = ./../../secrets/wireguard-server.age;
      owner = "root";
      group = "root";
    };
  };
}