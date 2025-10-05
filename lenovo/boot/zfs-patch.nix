{ lib, pkgs, ... }:

let
  zfs-src = pkgs.fetchurl {
    url = "https://github.com/openzfs/zfs/archive/pull/14013/head.tar.gz";
    hash = "sha256-X4PO6uf/ppEedR6ZAoWmrDRfHXxv2LuBThekRZOwmoA=";
  };
  nixpkgsFlake = builtins.getFlake "github:NixOS/nixpkgs/59e69648d345d6e8fef86158c555730fa12af9de";
  nixpkgsPkgs = nixpkgsFlake.outputs.packages.x86_64-linux;
in {
  nixpkgs.overlays = [
    (self: super: {
      zfs = super.zfs.overrideAttrs (old: {
        src = zfs-src;
      });
    })
  ];

  boot.kernelPackages = nixpkgsPkgs.linuxKernel.packages.linux_6_16.extend (self: super: {
    zfs_2_3 = super.zfs_2_3.overrideAttrs (old: {
      src = zfs-src;
    });
  });
}