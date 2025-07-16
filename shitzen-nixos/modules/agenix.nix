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
    zipline = {
      file = ./../../secrets/zipline.age;
      owner = "zipline";
      group = "zipline";
    };
    roundcube = {
      file = ./../../secrets/roundcube.age;
      owner = "roundcube";
      group = "roundcube";
    };
  };
}
