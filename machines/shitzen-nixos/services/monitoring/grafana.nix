{ config, inputs, lib, pkgs, ... }:

let
  oauthProxyConfig = ''
    # Bypass OAuth2 if request comes from localhost
    satisfy any;

    allow 0.0.0.0;
    deny all;

    auth_request /oauth2/auth;
    error_page 401 = /oauth2/sign_in?rd=$request_uri;

    auth_request_set $user $upstream_http_x_auth_request_user;
    auth_request_set $email $upstream_http_x_auth_request_email;
    proxy_set_header X-User $user;
    proxy_set_header X-Email $email;

    auth_request_set $auth_cookie $upstream_http_set_cookie;
    add_header Set-Cookie $auth_cookie;
  '';
in {
  networking.firewall.allowedTCPPorts = [
    config.services.grafana.settings.server.http_port
  ];

  services.grafana = {
    enable = true;
    provision = {
      enable = true;
      dashboards.settings.providers = [{
        name = "default";
        disableDeletion = true;
        options = {
          path = ./dashboards/default;
          foldersFromFilesStructure = true;
        };
      }];
      datasources.settings.datasources = [{
        name = "prometheus";
        type = "prometheus";
        url = "http://${config.networking.hostName}:3400/prometheus";
        isDefault = true;
        editable = false;
      }];
    };
    settings = {
      analytics = {
        reporting_enabled = false;
        feedback_links_enabled = false;
      };
      smtp = {
        enabled = true;
        from_address = "admin@kursu.dev";
      };
      server = {
        http_addr = "0.0.0.0";
        http_port = 3003;
        domain = "monitoring.kursu.dev";
        root_url = "https://monitoring.kursu.dev/grafana/";
        serve_from_sub_path = true;
      };
      security.admin_user = "admin";
      users.allow_sign_up = false;
    };
  };

  services.nginx = {
    virtualHosts."monitoring.kursu.dev" = {
      enableACME = true;
      forceSSL = true;
      locations = {
        "/grafana/" = lib.mkProxy {
          ip = "192.168.100.1";
          config = oauthProxyConfig;
          port = config.services.grafana.settings.server.http_port;
        };
        "/prometheus/" = lib.mkProxy {
          ip = "192.168.100.1";
          config = oauthProxyConfig;
          port = config.services.prometheus.port;
        };
      };
    };
  };
}