{ config, inputs, lib, pkgs, ... }:

let
  port = 3003;
in {
  services.grafana = {
    enable = true;
    provision = {
      enable = true;
      datasources.settings.datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          url = "https://monitoring.fuckk.lol/prometheus";
          isDefault = true;
          editable = false;
        }
      ];
    };
    settings = {
      analytics.reporting_enabled = false;
      smtp = {
        enabled = true;
        from_address = "vali@fuckk.lol";
      };
      server = {
        http_addr = "127.0.0.1";
        http_port = port;
        domain = "monitoring.fuckk.lol";
        root_url = "https://monitoring.fuckk.lol/grafana/";
        serve_from_sub_path = true;
      };
      security.admin_user = "admin";
      users.allow_sign_up = false;
    };
  };

  services.nginx = {
    virtualHosts."monitoring.fuckk.lol" = {
      enableACME = true;
      forceSSL = true;
      locations = {
        "/grafana/" = {
          proxyPass = "http://127.0.0.1:${toString port}";
          proxyWebsockets = true;
          recommendedProxySettings = true;
        };
        "/prometheus/" = {
          proxyPass = "http://127.0.0.1:3400";
          proxyWebsockets = true;
          recommendedProxySettings = true;
        };
      };
    };
  };
}