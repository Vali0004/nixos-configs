let
  mkProxy = import ../../modules/mkproxy.nix;
in {
  virtualisation = {
    docker.enable = true;
    podman.enable = true;
    oci-containers.containers = {
      dockge = {
        autoStart = true;
        image = "louislam/dockge:1";
        ports = [ "5001:5001" ];
        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock"
          "/data/services/dockge/data:/app/data:Z"
          "/data/services/stacks:/data/services/stacks"
        ];
        environment.DOCKGE_STACKS_DIR = "/data/services/stacks";
      };
    };
  };

  services.nginx.virtualHosts."dockge.fuckk.lol" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = mkProxy {
      port = 5001;
      webSockets = true;
    };
  };
}