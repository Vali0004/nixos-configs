{ config, pkgs, ... }:

{
  virtualisation = {
    podman.enable = true;
    oci-containers.containers = {
      dockge = {
        autoStart = true;
        image = "louislam/dockge:1";
        ports = [
          "5001:5001"
        ];
        volumes = [
          "/var/run/podman/podman.sock:/var/run/docker.sock"
          "/data/dockge/data:/app/data:Z"
          "/data/stacks:/data/stacks"
        ];
        environment = {
          DOCKGE_STACKS_DIR = "/data/stacks";
        };
      };
    };
  };
}