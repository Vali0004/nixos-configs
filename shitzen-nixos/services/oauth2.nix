{ config, inputs, lib, pkgs, ... }:

{
  services.oauth2-proxy = {
    cookie = {
      secure = true;
      refresh = "1h";
    };
    keyFile = "${config.age.secrets.oauth2.path}";
    email.domains = [ "fuckk.lol" ];
    enable = true;
    redirectURL = "https://watch.furryporn.ca/oauth2/callback";
    provider = "google";
    setXauthrequest = true;
  };

  services.nginx.virtualHosts = {
    "watch.furryporn.ca" = {
      locations."/oauth2" = {
        proxyPass = "http://localhost:4180";
      };
    };
  };
}