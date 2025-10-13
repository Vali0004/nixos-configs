{ config, inputs, lib, pkgs, ... }:

{
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
        url = "http://shitzen-container:${toString config.services.prometheus.port}/prometheus";
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
        from_address = "admin@fuckk.lol";
      };
      server = {
        http_addr = "0.0.0.0";
        http_port = 3000;
        domain = "monitoring.ajaxvpn.org";
        root_url = "https://monitoring.ajaxvpn.org/grafana/";
        serve_from_sub_path = true;
      };
      security.admin_user = "admin";
      users.allow_sign_up = false;
    };
  };
}