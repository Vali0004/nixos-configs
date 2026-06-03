{ config
, pkgs
, ... }:

{
  systemd.services.sqm = {
    wantedBy = [ "multi-user.target" ];

    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      ${pkgs.iproute2}/bin/tc qdisc replace dev ${config.router.wanInterface} root cake bandwidth 1750Mbit diffserv4 nat
      ${pkgs.iproute2}/bin/tc qdisc replace dev ${config.router.bridgeInterface} root cake bandwidth 1750Mbit diffserv4 nat
    '';
  };
}