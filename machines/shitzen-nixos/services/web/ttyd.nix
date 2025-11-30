{ config
, lib
, pkgs
, ... }:

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
  networking.firewall.allowedTCPPorts = [ 7681 ];

  services.ttyd = {
    enable = true;
    enableIPv6 = true;
    entrypoint = [ "${pkgs.bash}/bin/bash" ];
    port = 7681;
    writeable = true;
  };

  services.nginx.virtualHosts."monitoring.fuckk.lol" = {
    enableACME = true;
    forceSSL = true;
    locations = {
      "/" = lib.mkProxy {
        config = oauthProxyConfig;
        port = config.services.ttyd.port;
      };
    };
  };
}