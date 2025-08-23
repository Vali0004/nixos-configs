{ config, inputs, lib, pkgs, ... }:

let
  port = 3003;
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
  services.grafana = {
    enable = true;
    provision = {
      enable = true;
      dashboards.settings.providers = [{
        name = "generic";
        disableDeletion = true;
        options = {
          path = ./dashboards/generic;
          foldersFromFilesStructure = true;
        };
      }];
      datasources.settings.datasources = [
        {
          name = "prometheus";
          type = "prometheus";
          url = "http://localhost:3400/prometheus";
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
          extraConfig = oauthProxyConfig;
          proxyPass = "http://127.0.0.1:${toString port}";
          proxyWebsockets = true;
          recommendedProxySettings = true;
        };
        "/prometheus/" = {
          extraConfig = oauthProxyConfig;
          proxyPass = "http://127.0.0.1:3400";
          proxyWebsockets = true;
          recommendedProxySettings = true;
        };
      };
    };
  };
}