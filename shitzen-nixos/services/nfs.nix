{ config, inputs, lib, pkgs, ... }:

let
  statd-port = 4000;
  lockd-port = 4001;
  mountd-port = 4002;
in {
  networking.firewall.allowedTCPPorts = [
    111 # NFS Portmapper
    2049 # NFS Traffic
    statd-port
    lockd-port
    mountd-port
  ];

  services.nfs.server = {
    enable = true;
    statdPort = statd-port;
    lockdPort = lockd-port;
    mountdPort = mountd-port;
    exports = ''
      /data 10.0.0.31(rw,sync,no_subtree_check,no_root_squash) 10.0.0.201(rw,sync,no_subtree_check,no_root_squash) 10.0.0.134(rw,sync,no_subtree_check,no_root_squash)
    '';
  };
}