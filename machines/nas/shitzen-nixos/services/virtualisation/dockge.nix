{ lib
, ... }:

let
  stacksPath = "/data/services/stacks";
  dockgePath = "/data/services/dockge/data";
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
          "${dockgePath}:/app/data:Z"
          "${stacksPath}:${stacksPath}"
        ];
        environment.DOCKGE_STACKS_DIR = "${stacksPath}";
      };
    };
  };

  services.nginx.virtualHosts."dockge.kursu.dev" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = lib.mkProxy {
      ip = "192.168.100.1";
      port = 5001;
      webSockets = true;
    };
  };
}