{ config, ... }:

{
  # TODO: Setup a auto-deploy script
  environment.systemPackages = with pkgs; [
    nodejs_20
    nodePackages.pnpm
    nodePackages.yarn
  ];
  systemd.services.cors-anywhere = {
    enable = true;
    description = "Proxy to strip CORS from a request";
    unitConfig = {
      Type = "simple";
    };
    serviceConfig = {
      Environment = "PORT=8099";
      ExecStart = "/nix/store/j7dx1n6m5axf9r2bvly580x2ixx546wq-nodejs-20.18.1/bin/node/root/cors-anywhere/result/lib/node_modules/cors-anywhere/server.js";
    };
    wantedBy = [ "multi-user.target" ];
  };
}