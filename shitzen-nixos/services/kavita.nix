{ config, pkgs, ... }:

let
  mkProxy = import ./../modules/mkproxy.nix;
in {
  services.kavita = {
    enable = true;
    settings.Port = 8788;
    tokenKeyFile = config.age.secrets.kavita.path;
  };

  services.nginx.virtualHosts."manga.fuckk.lol" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = mkProxy {
      port = config.services.kavita.settings.Port;
    };
  };
}