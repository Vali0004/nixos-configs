{ config, pkgs, ... }:

let
  status = pkgs.callPackage ./package.nix {};
in {
  systemd.services.fuckk-lol-status = {
    enable = true;
    description = "Status daemon";
    serviceConfig = {
      Environment = [ "PORT=3000" ];
      ExecStart = "${pkgs.nodejs_20}/bin/node ${status}/lib/node_modules/fuckk-lol-status/server.js";
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
      extraConfig = ''
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-Proto "http";
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      '';
    };
  };
}