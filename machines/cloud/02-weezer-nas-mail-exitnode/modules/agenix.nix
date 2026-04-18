{ pkgs
, ... }:

{
  environment.systemPackages = with pkgs; [
    agenix
  ];

  age.secrets = {
    wireguard-mail-server = {
      file = ../../../../secrets/wireguard-mail-server.age;
      owner = "root";
      group = "root";
    };
  };
}