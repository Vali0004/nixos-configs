{ lib, pkgs, ... }:

let
  zfs-src = pkgs.fetchurl {
    url = "https://github.com/openzfs/zfs/archive/pull/14013/head.tar.gz";
    hash = "sha256-X4PO6uf/ppEedR6ZAoWmrDRfHXxv2LuBThekRZOwmoA=";
  };
in {
  nixpkgs.overlays = [
    (self: super: {
      zfs = super.zfs.overrideAttrs (old: {
        src = zfs-src;
      });
    })
  ];
}