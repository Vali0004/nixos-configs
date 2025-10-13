{ pkgs, ... }:

{
  programs.spicetify = {
    enable = true;
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
}
