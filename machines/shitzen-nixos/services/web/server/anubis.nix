{ config
, ... }:

let
  address = "192.168.100.1";
  base-metrics-port = 9002;
in {
  # TODO: Make a module called mkAnubis, as this is a mess.
  # It could be worse, but it's pretty bad...
  services.anubis.instances = {
    "hydra-server" = {
      settings = {
        TARGET = "http://${address}:${toString config.services.hydra.port}";
        BIND = ":${toString (config.services.hydra.port + 1)}";
        BIND_NETWORK = "tcp";
        METRICS_BIND = ":${toString base-metrics-port}";
        METRICS_BIND_NETWORK = "tcp";
      };
    };
    "git-server" = {
      settings = {
        TARGET = "http://${address}:${toString config.services.gitea.settings.server.HTTP_PORT}";
        BIND = ":${toString (config.services.gitea.settings.server.HTTP_PORT + 1)}";
        BIND_NETWORK = "tcp";
        METRICS_BIND = ":${toString (base-metrics-port + 1)}";
        METRICS_BIND_NETWORK = "tcp";
      };
    };
  };

  services.nginx = {
    appendHttpConfig = ''
      map $host $upstream {
        default "anubis";
        hydra.kursu.dev-${config.networking.hostId} "hydra-serer";
        git.kursu.dev-${config.networking.hostId} "git-server";
        hydra.kursu.dev "anubis-hydra";
        git.kursu.dev "anubis-git";
      }

      limit_req_zone $binary_remote_addr zone=hydra-server:8m rate=2r/s;
      limit_req_zone $binary_remote_addr zone=git-server:8m rate=2r/s;
      limit_req_status 429;
    '';

    upstreams = {
      git-server.servers."${address}:${toString config.services.gitea.settings.server.HTTP_PORT}" = { };
      hydra-server.servers."${address}:${toString config.services.hydra.port}" = { };
      anubis-hydra.servers."${address}${config.services.anubis.instances."hydra-server".settings.BIND}" = { };
      anubis-git.servers."${address}${config.services.anubis.instances."git-server".settings.BIND}" = { };
      anubis.servers."${address}${config.services.anubis.instances."hydra-server".settings.BIND}" = { };
    };
  };
}