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
    (import ./customPackages.nix)
    (import ./existingPackages.nix)
    (import ./mkNamespace.nix)
    (import ./mkPrometheusJob.nix)
    (import ./mkProxy.nix)
    (import ./scripts.nix { inherit config; })
  ];
}