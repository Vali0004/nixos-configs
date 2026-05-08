{ pkgs
, ... }:

{
  programs.spicetify = {
    enable = true;
    enabledExtensions = with pkgs.spicetifyExtensions; [
      adblock
      aiBandBlocker
      beautifulLyrics
      copyToClipboard
      fullAlbumDate
      fullAppDisplay
      hidePodcasts
      shuffle
      volumePercentage
    ];
    theme = pkgs.spicetifyThemes.sleek;
    colorScheme = "Elementary";
  };
}