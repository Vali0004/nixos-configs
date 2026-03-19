{ config
, lib
, pkgs
, ... }:

{
  services.oauth2-proxy = {
    cookie = {
      secure = true;
      refresh = "1h";
    };
    keyFile = config.age.secrets.oauth2-proxy.path;
    email.domains = [ "lab004.dev" ];
    enable = true;
    nginx = {
      domain = "monitoring.lab004.dev";
      virtualHosts = {
        "monitoring.lab004.dev" = {
          allowed_email_domains = [
            "lab004.dev"
            "fuckk.lol"
            "nanitehosting.com"
          ];
        };
      };
    };
    provider = "google";
    redirectURL = "https://monitoring.lab004.dev/oauth2/callback";
    setXauthrequest = true;
    skipAuthRegexes = [
      "^/prometheus(/.*)?$"
    ];
  };

  services.nginx.virtualHosts."monitoring.lab004.dev" = {
    enableACME = true;
    forceSSL = true;
    locations = {
      "/oauth2/" = lib.mkProxy {
        ip = "127.0.0.1";
        port = 4180;
      };
    };
  };
}