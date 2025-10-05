{ lib, pkgs, ... }:

let
  zfs-src = pkgs.fetchurl {
    url = "https://github.com/openzfs/zfs/archive/pull/14013/head.tar.gz";
    hash = "sha256-X4PO6uf/ppEedR6ZAoWmrDRfHXxv2LuBThekRZOwmoA=";
  };
  nixpkgs = builtins.getFlake "github:NixOS/nixpkgs/59e69648d345d6e8fef86158c555730fa12af9de";
  pkgsOverride = (nixpkgs.legacyPackages.x86_64-linux.override {
    config = {
      allowUnfree = true;
      hostPlatform = "x86_64-linux";
      permittedInsecurePackages = [
        "libxml2-2.13.8"
        "qtwebengine-5.15.19"
      ];
    };
  });
in {
  nixpkgs.pkgs = pkgsOverride;
  nixpkgs.overlays = [
    (self: super: {
      zfs = super.zfs.overrideAttrs (old: {
        src = zfs-src;
      });
    })
  ];

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_16.extend (self: super: {
    zfs_2_3 = super.zfs_2_3.overrideAttrs (old: {
      src = zfs-src;
    });
  });
}