{ pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [ 9103 ];

  systemd.services.zfs-fragmentation = {
    serviceConfig.ExecStart = "${pkgs.zfs-fragmentation}/bin/zfs-fragmentation";
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Restart = "always";
  };
}