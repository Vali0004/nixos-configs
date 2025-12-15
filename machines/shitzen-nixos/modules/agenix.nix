{ config, lib, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.agenix ];
  age.secrets = {
    cleclerc-nanitehosting-com = {
      file = ../../../secrets/cleclerc-nanitehosting-com.age;
      owner = "nginx";
      group = "nginx";
    };
    do-not-reply-fuckk-lol = {
      file = ../../../secrets/do-not-reply-fuckk-lol.age;
      owner = config.services.gitea.user;
      group = config.services.gitea.group;
    };
    git-fuckk-lol-db = {
      file = ../../../secrets/git-fuckk-lol-db.age;
      owner = "postgres";
      group = config.services.gitea.group;
      mode = "0440";
    };
    hydra-github-token = {
      file = ../../../secrets/hydra-github-token.age;
      owner = "hydra";
    };
    hydra-runner-ajax-github-token = {
      file = ../../../secrets/hydra-runner-ajax-github-token.age;
      owner = "hydra";
    };
    kavita = {
      file = ../../../secrets/kavita.age;
      owner = "kavita";
      group = "kavita";
    };
    matrix = {
      file = ../../../secrets/matrix.age;
      owner = "matrix-synapse";
      group = "matrix-synapse";
    };
    nextcloud-admin-password = {
      file = ../../../secrets/nextcloud-admin-password.age;
      owner = "nextcloud";
      group = "nextcloud";
    };
    nix-netrc = {
      file = ../../../secrets/nix-netrc.age;
      owner = "hydra";
      group = "hydra";
    };
    oauth2 = {
      file = ../../../secrets/oauth2.age;
      owner = "nginx";
      group = "nginx";
    };
    oauth2-proxy = {
      file = ../../../secrets/oauth2-proxy.age;
      owner = "nginx";
      group = "nginx";
    };
    prowlarr-api = {
      file = ../../../secrets/prowlarr-api.age;
      owner = "root";
      group = "root";
    };
    radarr-api = {
      file = ../../../secrets/radarr-api.age;
      owner = "root";
      group = "root";
    };
    sogo-db-password = {
      file = ../../../secrets/sogo-db-password.age;
      owner = "postgres";
      group = "sogo";
      mode = "0444";
    };
    sonarr-api = {
      file = ../../../secrets/sonarr-api.age;
      owner = "root";
      group = "root";
    };
    vali-fuckk-lol = {
      file = ../../../secrets/vali-fuckk-lol.age;
      owner = "nginx";
      group = "nginx";
    };
    wireguard = {
      file = ../../../secrets/wireguard.age;
      owner = "root";
      group = "root";
    };
    zipline = {
      file = ../../../secrets/zipline.age;
      owner = "root";
      group = "root";
    };
  };
}
