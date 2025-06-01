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
          "/var/run/docker.sock:/var/run/docker.sock"
          "./data:/app/data"
          "/data/dockge/stacks:/data/dockge/stacks"
        ];
        entrypoint = "/data/dockge/dockge-run";
        environment = {
          DOCKGE_STACKS_DIR = "/data/dockge/stacks";
        };
        extraOptions = [ "--cap-add=NET_ADMIN" ];
      };
    };
  };
}