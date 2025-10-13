{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.programs.spicetify.enable {
    programs.spicetify = {
      enabledExtensions = with pkgs.spicetifyExtensions; [
        adblock
        autoSkipVideo
        beautifulLyrics
        hidePodcasts
        shuffle
      ];
      theme = pkgs.spicetifyThemes.sleek;
      colorScheme = "Elementary";
    };
  };
}
