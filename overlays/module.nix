{ config
, ... }:

{
  nixpkgs.config.permittedInsecurePackages = [
    # Required for agenix
    "libxml2-2.13.8"
    # Required for jellyfin-media-player
    "qtwebengine-5.15.19"
  ];

  nixpkgs.overlays = [
    (import lib/mkNamespace.nix)
    (import lib/mkPrometheusJob.nix)
    (import lib/mkProxy.nix)
    (import ./customPackages.nix)
    (import ./existingPackages.nix)
    (import ./scripts.nix { inherit config; })
  ];
}