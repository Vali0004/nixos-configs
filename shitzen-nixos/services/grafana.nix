{ config, inputs, lib, pkgs, ... }:

let
  port = 3003;
in {
  services.grafana = {
    enable = true;
    settings = {
      smtp = {
        enabled = true;
        from_address = "vali@fuckk.lol";
      };
      server = {
        http_addr = "127.0.0.1";
        http_port = port;
        domain = "grafana.fuckk.lol";
        serve_from_sub_path = true;
      };
    };
  };

  services.nginx = {
    virtualHosts."grafana.fuckk.lol" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString port}";
        proxyWebsockets = true;
        recommendedProxySettings = true;
      };
    };
  };
}