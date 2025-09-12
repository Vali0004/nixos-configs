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
    maddy-mail-fuckk-lol = {
      file = ./../../secrets/maddy-mail-fuckk-lol.age;
      owner = "nginx";
      group = "nginx";
    };
    matrix = {
      file = ./../../secrets/matrix.age;
      owner = "matrix-synapse";
      group = "matrix-synapse";
    };
    oauth2 = {
      file = ./../../secrets/oauth2.age;
      owner = "nginx";
      group = "nginx";
    };
    oauth2-proxy = {
      file = ./../../secrets/oauth2-proxy.age;
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
    prowlarr-api = {
      file = ./../../secrets/prowlarr-api.age;
      owner = "root";
      group = "root";
    };
    radarr-api = {
      file = ./../../secrets/radarr-api.age;
      owner = "root";
      group = "root";
    };
    sonarr-api = {
      file = ./../../secrets/sonarr-api.age;
      owner = "root";
      group = "root";
    };
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
