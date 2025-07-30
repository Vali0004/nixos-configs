{ config, inputs, lib, pkgs, ... }:

{
  services.oauth2-proxy = {
    cookie = {
      secure = true;
      refresh = "1h";
    };
    keyFile = config.age.secrets.oauth2.path;
    email.domains = [ "fuckk.lol" ];
    enable = true;
    redirectURL = "https://oauth.fuckk.lol/oauth2/callback";
    provider = "google";
    setXauthrequest = true;
  };
}