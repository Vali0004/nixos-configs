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
          "/var/lib/dockge/data:/app/data:Z"
          "/var/lib/stacks:/var/lib/stacks"
        ];
        environment.DOCKGE_STACKS_DIR = "/var/lib/stacks";
      };
    };
  };

  services.nginx.virtualHosts."dockge-vps.fuckk.lol" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = mkProxy {
      port = 5001;
      webSockets = true;
    };
  };
}