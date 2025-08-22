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
          allowed_emails = [
            "diorcheats.vali@gmail.com"
          ];
          allowed_email_domains = [
            "fuckk.lol"
          ];
        };
      };
    };
    provider = "google";
    setXauthrequest = true;
  };
}