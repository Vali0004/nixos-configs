{ config, pkgs, ... }:

{
  virtualisation = {
    #podman.enable = true;
    #oci-containers.containers = {
    #  dockge = {
    #    image = "$GITHUB_BRANCH$:louislam/dockge:master$";
    #    entrypoint = "/data/dockge";
    #  };
    #};
  };
}