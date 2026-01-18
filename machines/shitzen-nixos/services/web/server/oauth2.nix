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
    email.domains = [ "fuckk.lol" ];
    enable = true;
    nginx = {
      domain = "monitoring.kursu.dev";
      virtualHosts = {
        "monitoring.kursu.dev" = {
          allowed_email_domains = [
            "fuckk.lol"
            "nanitehosting.com"
          ];
        };
      };
    };
    provider = "google";
    redirectURL = "https://monitoring.kursu.dev/oauth2/callback";
    setXauthrequest = true;
    skipAuthRegexes = [
      "^/prometheus(/.*)?$"
    ];
  };

  services.nginx.virtualHosts."monitoring.kursu.dev" = {
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