{ config, lib, pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.agenix
  ];
  age.secrets = {
    oauth2 = {
      file = ./../../secrets/oauth2.age;
      owner = "nginx";
      group = "nginx";
    };
    pterodactyl = {
      file = ./../../secrets/pterodactyl.age;
      owner = "pterodactyl";
      group = "pterodactyl";
    };
    vali-mail-fuckk-lol = {
      file = ./../../secrets/vali-mail-fuckk-lol.age;
      owner = "nginx";
      group = "nginx";
    };
    zipline = {
      file = ./../../secrets/zipline.age;
      owner = "zipline";
      group = "zipline";
    };
  };
}
