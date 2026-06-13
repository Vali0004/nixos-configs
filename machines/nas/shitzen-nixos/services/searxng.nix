{ config
, lib
, ... }:

{
  networking.firewall.allowedTCPPorts = [
    config.services.searx.settings.server.port
  ];

  services.searx = {
    enable = true;
    redisCreateLocally = true;
    settings = {
      general = {
        debug = false;
        instance_name = "SearXNG Instance";
        donation_url = false;
        contact_url = false;
        privacypolicy_url = false;
        enable_metrics = false;
      };
      server = {
        port = 8888;
        bind_address = "0.0.0.0";
        secret_key = "2WuiELU6ojAlkXlrYJDUoD994tTLbP";
        method = "GET";
      };
      search = {
        formats = [
          "html"
          "json"
        ];
      };
    };
  };

  services.nginx.virtualHosts."kms.lab004.dev" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = lib.mkProxy {
      ip = "192.168.100.1";
      port = 3200;
    };
  };
}