{ config, inputs, lib, pkgs, ... }:

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
      domain = "monitoring.fuckk.lol";
      virtualHosts = {
        "monitoring.fuckk.lol" = {
          allowed_email_domains = [
            "fuckk.lol"
            "nanitehosting.com"
          ];
        };
      };
    };
    provider = "google";
    redirectURL = "https://monitoring.fuckk.lol/oauth2/callback";
    setXauthrequest = true;
  };

  services.nginx = {
    virtualHosts."monitoring.fuckk.lol" = {
      enableACME = true;
      forceSSL = true;
      locations = {
        "/oauth2/" = {
          proxyPass = "http://127.0.0.1:4180";
          proxyWebsockets = true;
          recommendedProxySettings = true;
        };
      };
    };
  };
}