{ lib
, pkgs
, ... }:

let
  overlayProxy = (import lib/mkProxy.nix) pkgs pkgs;
  overlayProm = (import lib/mkPrometheusJob.nix) pkgs pkgs;
  overlayNs = (import lib/mkNamespace.nix) pkgs pkgs;
in {
  lib = lib.extend (self: super: {
    mkProxy = overlayProxy.lib.mkProxy;
    mkPrometheusJob = overlayProm.lib.mkPrometheusJob;
    mkNamespace = overlayNs.lib.mkNamespace;
  });
}