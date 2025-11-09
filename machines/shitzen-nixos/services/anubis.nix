{
  services.anubis = {
    instances = {
      "hydra-server" = {
        settings = {
          TARGET = "http://192.168.100.1:3001";
          BIND = ":3002";
          BIND_NETWORK = "tcp";
          METRICS_BIND = ":9002";
          METRICS_BIND_NETWORK = "tcp";
        };
      };
      "git-server" = {
        settings = {
          TARGET = "http://192.168.100.1:3900";
          BIND = ":3901";
          BIND_NETWORK = "tcp";
          METRICS_BIND = ":9003";
          METRICS_BIND_NETWORK = "tcp";
        };
      };
    };
  };

  services.nginx = {
    appendHttpConfig = ''
      map $host $upstream {
        default "anubis";
        hydra.fuckk.lol-0626c0ac "hydra-serer";
        git.fuckk.lol-0626c0ac "git-server";
        hydra.fuckk.lol "anubis-hydra";
        git.fuckk.lol "anubis-git";
      }

      limit_req_zone $binary_remote_addr zone=hydra-server:8m rate=2r/s;
      limit_req_zone $binary_remote_addr zone=git-server:8m rate=2r/s;
      limit_req_status 429;
    '';

    upstreams = {
      git-server.servers."192.168.100.1:3900" = { };
      hydra-server.servers."192.168.100.1:3001" = { };
      anubis-hydra.servers."192.168.100.1:3002" = { };
      anubis-git.servers."192.168.100.1:3901" = { };
      anubis-default.servers."192.168.100.1:3002" = { };
    };
  };
}