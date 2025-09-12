{ pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [ 9103 ];

  systemd.services.zfs-fragmentation = {
    serviceConfig.ExecStart = "${zfs-fragmentation}/bin/zfs-fragmentation";
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Restart = "always";
  };
}