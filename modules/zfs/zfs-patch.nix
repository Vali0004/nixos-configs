{ config
, lib
, pkgs
, ... }:

{
  config = lib.mkIf config.zfs.enable {
    boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_18;
    boot.zfs.package = pkgs.zfs_unstable;
  };
}