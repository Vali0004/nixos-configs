{ lib
, ... }:

let
  stacksPath = "/data/services/stacks";
  dockgePath = "/data/services/dockge/data";
in {
  virtualisation = {
    docker = {
      enable = true;
      daemon.settings = {
        ipv6 = true;
        "default-address-pools" = [
          {
            base = "10.200.0.0/16";
            size = 24;
          }
        ];
      };
    };
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

  services.nginx.virtualHosts."dockge.lab004.dev" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = lib.mkProxy {
      ip = "192.168.100.1";
      port = 5001;
      webSockets = true;
    };
  };
}