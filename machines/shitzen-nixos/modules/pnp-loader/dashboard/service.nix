{ config, pkgs, ... }:

let
  pnp-dashboard = pkgs.callPackage ./package.nix {};
  targetDir = "/var/lib/pnp-dashboard";
in
{
  systemd.services.pnp-dashboard-deploy = {
    description = "Deploy pnp-dashboard to /var/lib for nginx";
    after = [ "network.target" ];
    before = [ "nginx.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "deploy-pnp-dashboard" ''
        set -eu
        echo "Copying pnp-dashboard to ${targetDir}..."
        rm -rf ${targetDir}
        cp -r ${pnp-dashboard} ${targetDir}
        chown -R nginx:nginx ${targetDir}
      '';
    };
  };

  services.nginx.virtualHosts."manage.pnploader.ru" = {
    enableACME = true;
    forceSSL = true;
    root = targetDir;
    locations."/" = {
      index = "index.html";
    };
    locations."~* \.(?:ico|css|js|gif|jpe?g|png|woff2?|eot|ttf|svg)$" = {
      root = targetDir;
      extraConfig = ''
        expires 6M;
        access_log off;
      '';
    };
  };
}