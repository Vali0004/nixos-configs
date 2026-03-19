{
  services.nginx = {
    enable = true;
    enableReload = true;

    recommendedTlsSettings = true;
    recommendedProxySettings = true;

    appendConfig = ''
      stream {
        map $ssl_preread_server_name $backend {
          status.lab004.dev 127.0.0.1:443; # handled by HTTP block
          default          10.127.0.3:443; # catch-all
        }

        server {
          listen 74.208.44.130:443;
          proxy_pass $backend;
          ssl_preread on;
        }
      }
    '';
  };

  services.nginx.virtualHosts."cache.lab004.dev" = {
    enableACME = false;
    forceSSL = false;
    listen = [
      { addr = "127.0.0.1"; port = 4444; }
    ];
    locations = {
      "/private/" = {
        alias = "/var/lib/cdn/";
        index = "index.htm";
        extraConfig = ''
          autoindex on;
          autoindex_exact_size off;
        '';
      };
    };
  };
}