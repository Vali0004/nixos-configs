{ config
, pkgs
, ... }:

{
  services.gitea-actions-runner.instances = {
    "kursu" = {
      enable = false;
      name = "kursu";
      url = "https://git.kursu.dev";
      tokenFile = config.age.secrets.gitea-runner-token.path;
      labels = [
        "ubuntu-latest:docker://gitea/runner-images:ubuntu-24.04"
        "ubuntu-24.04:docker://gitea/runner-images:ubuntu-24.04"
        "node20:docker://node:20-bookworm"
        "alpine:docker://alpine:3.20"
      ];
    };
  };

  users = {
    users.gitea-runner = {
      group = "gitea-runner";
      description = "Used for running CI";
      home = "/var/lib/gitea-runner/";
      isSystemUser = true;
      createHome = true;
      extraGroups = [
        "docker"
      ];
    };
    groups.gitea-runner = {};
  };
}