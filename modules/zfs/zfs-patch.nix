{ config
, lib
, pkgs
, ... }:

{
  config = lib.mkIf config.zfs.enable {
    #boot.kernelPackages = pkgs.linuxKernel.packages.linux_7_0;
    # use the overlay-patched set from overlays/zfsPackages.nix
    # plain pkgs.linuxPackages resolves via linuxKernel.packages and ships a mismatched zfs module
    boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_6_18;
    boot.zfs.package = pkgs.zfs_unstable;
  };
}
