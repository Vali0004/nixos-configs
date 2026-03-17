{ config, lib, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.agenix ];
  age.secrets = {
    cleclerc-nanitehosting-com = {
<<<<<<<< Updated upstream:machines/nas/shitzen-nixos/modules/agenix.nix
      file = ../../../../secrets/cleclerc-nanitehosting-com.age;
========
      file = ../../../../../secrets/cleclerc-nanitehosting-com.age;
>>>>>>>> Stashed changes:machines/home/nas/shitzen-nixos/modules/agenix.nix
      owner = "nginx";
      group = "nginx";
    };
    do-not-reply-kursu-dev = {
<<<<<<<< Updated upstream:machines/nas/shitzen-nixos/modules/agenix.nix
      file = ../../../../secrets/do-not-reply-kursu-dev.age;
========
      file = ../../../../../secrets/do-not-reply-kursu-dev.age;
>>>>>>>> Stashed changes:machines/home/nas/shitzen-nixos/modules/agenix.nix
      owner = config.services.gitea.user;
      group = config.services.gitea.group;
    };
    git-kursu-dev-db = {
<<<<<<<< Updated upstream:machines/nas/shitzen-nixos/modules/agenix.nix
      file = ../../../../secrets/git-kursu-dev-db.age;
========
      file = ../../../../../secrets/git-kursu-dev-db.age;
>>>>>>>> Stashed changes:machines/home/nas/shitzen-nixos/modules/agenix.nix
      owner = "postgres";
      group = config.services.gitea.group;
      mode = "0440";
    };
    gitea-runner-token = {
<<<<<<<< Updated upstream:machines/nas/shitzen-nixos/modules/agenix.nix
      file = ../../../../secrets/gitea-runner-token.age;
========
      file = ../../../../../secrets/gitea-runner-token.age;
>>>>>>>> Stashed changes:machines/home/nas/shitzen-nixos/modules/agenix.nix
      owner = "gitea-runner";
      group = "gitea-runner";
      mode = "0440";
    };
    grafana-secret = {
      file = ../../../../secrets/grafana-secret.age;
      owner = "grafana";
      group = "grafana";
      mode = "0440";
    };
    hydra-github-token = {
<<<<<<<< Updated upstream:machines/nas/shitzen-nixos/modules/agenix.nix
      file = ../../../../secrets/hydra-github-token.age;
      owner = "hydra";
    };
    hydra-runner-ajax-github-token = {
      file = ../../../../secrets/hydra-runner-ajax-github-token.age;
      owner = "hydra";
    };
    kavita = {
      file = ../../../../secrets/kavita.age;
========
      file = ../../../../../secrets/hydra-github-token.age;
      owner = "hydra";
    };
    hydra-runner-ajax-github-token = {
      file = ../../../../../secrets/hydra-runner-ajax-github-token.age;
      owner = "hydra";
    };
    kavita = {
      file = ../../../../../secrets/kavita.age;
>>>>>>>> Stashed changes:machines/home/nas/shitzen-nixos/modules/agenix.nix
      owner = "kavita";
      group = "kavita";
    };
    matrix = {
<<<<<<<< Updated upstream:machines/nas/shitzen-nixos/modules/agenix.nix
      file = ../../../../secrets/matrix.age;
========
      file = ../../../../../secrets/matrix.age;
>>>>>>>> Stashed changes:machines/home/nas/shitzen-nixos/modules/agenix.nix
      owner = "matrix-synapse";
      group = "matrix-synapse";
    };
    nextcloud-admin-password = {
<<<<<<<< Updated upstream:machines/nas/shitzen-nixos/modules/agenix.nix
      file = ../../../../secrets/nextcloud-admin-password.age;
========
      file = ../../../../../secrets/nextcloud-admin-password.age;
>>>>>>>> Stashed changes:machines/home/nas/shitzen-nixos/modules/agenix.nix
      owner = "nextcloud";
      group = "nextcloud";
    };
    nix-netrc = {
<<<<<<<< Updated upstream:machines/nas/shitzen-nixos/modules/agenix.nix
      file = ../../../../secrets/nix-netrc.age;
========
      file = ../../../../../secrets/nix-netrc.age;
>>>>>>>> Stashed changes:machines/home/nas/shitzen-nixos/modules/agenix.nix
      owner = "hydra";
      group = "hydra";
    };
    oauth2 = {
<<<<<<<< Updated upstream:machines/nas/shitzen-nixos/modules/agenix.nix
      file = ../../../../secrets/oauth2.age;
========
      file = ../../../../../secrets/oauth2.age;
>>>>>>>> Stashed changes:machines/home/nas/shitzen-nixos/modules/agenix.nix
      owner = "nginx";
      group = "nginx";
    };
    oauth2-proxy = {
<<<<<<<< Updated upstream:machines/nas/shitzen-nixos/modules/agenix.nix
      file = ../../../../secrets/oauth2-proxy.age;
========
      file = ../../../../../secrets/oauth2-proxy.age;
>>>>>>>> Stashed changes:machines/home/nas/shitzen-nixos/modules/agenix.nix
      owner = "nginx";
      group = "nginx";
    };
    prowlarr-api = {
<<<<<<<< Updated upstream:machines/nas/shitzen-nixos/modules/agenix.nix
      file = ../../../../secrets/prowlarr-api.age;
========
      file = ../../../../../secrets/prowlarr-api.age;
>>>>>>>> Stashed changes:machines/home/nas/shitzen-nixos/modules/agenix.nix
      owner = "root";
      group = "root";
    };
    radarr-api = {
<<<<<<<< Updated upstream:machines/nas/shitzen-nixos/modules/agenix.nix
      file = ../../../../secrets/radarr-api.age;
========
      file = ../../../../../secrets/radarr-api.age;
>>>>>>>> Stashed changes:machines/home/nas/shitzen-nixos/modules/agenix.nix
      owner = "root";
      group = "root";
    };
    #sogo-db-password = {
<<<<<<<< Updated upstream:machines/nas/shitzen-nixos/modules/agenix.nix
    #  file = ../../../../secrets/sogo-db-password.age;
========
    #  file = ../../../../../secrets/sogo-db-password.age;
>>>>>>>> Stashed changes:machines/home/nas/shitzen-nixos/modules/agenix.nix
    #  owner = "postgres";
    #  group = "sogo";
    #  mode = "0444";
    #};
    sonarr-api = {
<<<<<<<< Updated upstream:machines/nas/shitzen-nixos/modules/agenix.nix
      file = ../../../../secrets/sonarr-api.age;
========
      file = ../../../../../secrets/sonarr-api.age;
>>>>>>>> Stashed changes:machines/home/nas/shitzen-nixos/modules/agenix.nix
      owner = "root";
      group = "root";
    };
    vali-kursu-dev = {
<<<<<<<< Updated upstream:machines/nas/shitzen-nixos/modules/agenix.nix
      file = ../../../../secrets/vali-kursu-dev.age;
========
      file = ../../../../../secrets/vali-kursu-dev.age;
>>>>>>>> Stashed changes:machines/home/nas/shitzen-nixos/modules/agenix.nix
      owner = "nginx";
      group = "nginx";
    };
    whcms-db-pass = {
<<<<<<<< Updated upstream:machines/nas/shitzen-nixos/modules/agenix.nix
      file = ../../../../secrets/whcms-db-pass.age;
========
      file = ../../../../../secrets/whcms-db-pass.age;
>>>>>>>> Stashed changes:machines/home/nas/shitzen-nixos/modules/agenix.nix
      owner = "nginx";
      group = "nginx";
    };
    wireguard = {
<<<<<<<< Updated upstream:machines/nas/shitzen-nixos/modules/agenix.nix
      file = ../../../../secrets/wireguard.age;
========
      file = ../../../../../secrets/wireguard.age;
>>>>>>>> Stashed changes:machines/home/nas/shitzen-nixos/modules/agenix.nix
      owner = "root";
      group = "root";
    };
    zipline = {
<<<<<<<< Updated upstream:machines/nas/shitzen-nixos/modules/agenix.nix
      file = ../../../../secrets/zipline.age;
========
      file = ../../../../../secrets/zipline.age;
>>>>>>>> Stashed changes:machines/home/nas/shitzen-nixos/modules/agenix.nix
      owner = "root";
      group = "root";
    };
  };
}
