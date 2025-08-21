{ config, lib, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.agenix ];
  age.secrets = {
    convoy = {
      file = ./../../secrets/convoy.age;
      owner = "nginx";
      group = "nginx";
    };
    cleclerc-mail-nanitehosting-com = {
      file = ./../../secrets/cleclerc-mail-nanitehosting-com.age;
      owner = "nginx";
      group = "nginx";
    };
    hydra-github-token = {
      file = ./../../secrets/hydra-github-token.age;
      owner = "hydra";
    };
    oauth2 = {
      file = ./../../secrets/oauth2.age;
      owner = "nginx";
      group = "nginx";
    };
    pnp-api = {
      file = ./../../secrets/pnp-api.age;
      owner = "nginx";
      group = "nginx";
    };
    pnp-loader = {
      file = ./../../secrets/pnp-loader.age;
      owner = "nginx";
      group = "nginx";
    };
    #pterodactyl = {
    #  file = ./../../secrets/pterodactyl.age;
    #  owner = "pterodactyl";
    #  group = "pterodactyl";
    #};
    vali-mail-fuckk-lol = {
      file = ./../../secrets/vali-mail-fuckk-lol.age;
      owner = "nginx";
      group = "nginx";
    };
    zipline = {
      file = ./../../secrets/zipline.age;
      owner = "root";
      group = "root";
    };
    wireguard = {
      file = ./../../secrets/wireguard.age;
      owner = "root";
      group = "root";
    };
    wireguard-down = {
      file = ./../../secrets/wireguard-down.age;
      owner = "root";
      group = "root";
    };
  };
}
