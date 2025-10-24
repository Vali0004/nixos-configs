{ config, inputs, lib, pkgs, ... }:

{
  services.nginx = {
    enable = true;
    enableReload = true;

    recommendedTlsSettings = true;

    appendConfig = ''
      stream {
        map $ssl_preread_server_name $backend {
          status.fuckk.lol 127.0.0.1:443;  # handled by HTTP block
          xdp.fuckk.lol    127.0.0.1:443;  # handled by HTTP block
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
}