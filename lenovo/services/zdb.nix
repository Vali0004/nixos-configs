{ pkgs, ... }:

let
  zfsUtil = builtins.getFlake "github:cleverca22/zfs-utils";
  zfsUtilPkgs = zfsUtil.outputs.packages.x86_64-linux;
in {
  networking.firewall.allowedTCPPorts = [ 9103 ];

  systemd.services.zfs-fragmentation = {
    serviceConfig.ExecStart = "${zfsUtilPkgs.zfs-fragmentation}/bin/zfs-fragmentation";
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Restart = "always";
  };
}