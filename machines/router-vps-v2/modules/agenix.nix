{ pkgs
, ... }:

{
  environment.systemPackages = with pkgs; [
    agenix
  ];

  age.secrets = {
    wireguard-server = {
      file = ../../../secrets/wireguard-server.age;
      owner = "root";
      group = "root";
    };
  };
}