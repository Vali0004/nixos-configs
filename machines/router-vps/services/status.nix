{ pkgs
, ... }:

{
  systemd.services.kursu-dev-status = {
    enable = true;
    description = "Status daemon";
    serviceConfig = {
      Environment = [ "PORT=3000" ];
      ExecStart = "${pkgs.nodejs_20}/bin/node ${pkgs.kursu-dev-status}/lib/node_modules/kursu-dev-status/server.js";
    };
    wantedBy = [ "multi-user.target" ];
  };

  services.nginx.virtualHosts."status.fuckk.lol" = {
    enableACME = true;
    forceSSL = true;
    listen = [
      { addr = "127.0.0.1"; port = 80; }
      { addr = "127.0.0.1"; port = 443; ssl = true; }
    ];
    locations."/" = {
      proxyPass = "http://127.0.0.1:3000";
      proxyWebsockets = true;
    };
  };
}