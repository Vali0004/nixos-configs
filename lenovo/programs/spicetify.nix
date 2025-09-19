{ config, lib, pkgs, ... }:

let
  spice = builtins.getFlake "github:Gerg-L/spicetify-nix";
  spicePkgs = spice.outputs.legacyPackages.x86_64-linux;
in {
  imports = [
    spice.nixosModules.default
  ];
  programs.spicetify = {
    enable = true;
    enabledExtensions = with spicePkgs.extensions; [
      adblock
      autoSkipVideo
      beautifulLyrics
      hidePodcasts
      shuffle
    ];
    theme = spicePkgs.themes.sleek;
    colorScheme = "Elementary";
  };
}
