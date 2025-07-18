{ config, inputs, lib, pkgs, ... }:

{
  systemd.services.oauth2-proxy.serviceConfig.EnvironmentFile = "${config.age.secrets.oauth2.path}";
  services.oauth2-proxy = {
    cookie = {
      secret = "";
      secure = true;
      refresh = "1h";
    };
    email.domains = [ "fuckk.lol" ];
    enable = true;
    redirectURL = "https://watch.furryporn.ca/oauth2/callback";
    provider = "google";
    setXauthrequest = true;
    clientID = "";
    clientSecret = "";
    extraConfig = {
      client_id = "$OAUTH2_PROXY_CLIENT_ID";
      client_secret = "$OAUTH2_PROXY_CLIENT_SECRET";
      cookie_secret = "$OAUTH2_PROXY_COOKIE_SECRET";
    };
  };

  services.nginx.virtualHosts = {
    "watch.furryporn.ca" = {
      locations."/oauth2" = {
        proxyPass = "http://localhost:4180";
      };
    };
  };
}