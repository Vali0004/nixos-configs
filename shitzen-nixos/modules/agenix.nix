{ config, lib, pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.agenix
  ];
  age.secrets = {
    pterodactyl = {
      file = ./../../secrets/pterodactyl.age;
      owner = "pterodactyl";
      group = "pterodactyl";
    };
  };
}