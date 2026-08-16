{ config
, lib
, pkgs
, ... }:

{
  config = lib.mkIf config.zfs.enable {
    boot.kernelPackages = pkgs.linuxKernel.packages.linux_7_0;
    boot.zfs.package = pkgs.zfs_unstable;
  };
}