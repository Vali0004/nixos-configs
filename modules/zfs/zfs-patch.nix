{ lib
, pkgs
, ... }:

let
  zfs-src = pkgs.fetchurl {
    url = "https://github.com/openzfs/zfs/archive/pull/14013/head.tar.gz";
    hash = "sha256-H1Q7lEMViDCyd7PuiHrQ3DvptWOJ41xcOzosgcwUwjE=";
  };
in {
  nixpkgs.overlays = [(self: super: {
    zfs_2_4 = super.zfs_2_4.overrideAttrs (old: {
      src = zfs-src;
      patches = [];
      postPatch =
        lib.replaceStrings
          [ "substituteInPlace ./lib/libshare/os/linux/nfs.c" "./lib/libshare/smb.h" ]
          [ "substituteInPlace ./lib/libzfs/os/linux/libzfs_share_nfs.c" "./lib/libzfs/libzfs_share.h" ]
          (old.postPatch or "");
    });
  })];

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_12.extend (self: super: {
    zfs_2_4 = super.zfs_2_4.overrideAttrs (old: {
      src = zfs-src;
      patches = [];
    });
  });

  boot.zfs.package = pkgs.zfs_2_4;
}