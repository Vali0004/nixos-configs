{ lib
, writeShellScriptBin
, makeDesktopItem
, symlinkJoin
, syncplay }:

let
  pname = "syncplay-clever";

  script = writeShellScriptBin "syncplay-clever" ''
    ${syncplay}/bin/syncplay -a ext.earthtools.ca:1337 -r vem -p hunter2
  '';

  desktopItems = makeDesktopItem {
    name = pname;

    exec = "${script}/bin/${pname} %U";

    icon = "syncplay";

    desktopName = "Syncplay (Clever)";

    categories = [
      "AudioVideo"
      "Audio"
      "Video"
    ];

    mimeTypes = [
      "audio/ac3"
      "audio/mp4"
      "audio/mpeg"
      "audio/vnd.rn-realaudio"
      "audio/vorbis"
      "audio/x-adpcm"
      "audio/x-matroska"
      "audio/x-mp2"
      "audio/x-mp3"
      "audio/x-ms-wma"
      "audio/x-vorbis"
      "audio/x-wav"
      "audio/mpegurl"
      "audio/x-mpegurl"
      "audio/x-pn-realaudio"
      "audio/x-scpls"
      "video/avi"
      "video/mp4"
      "video/flv"
      "video/mpeg"
      "video/quicktime"
      "video/vnd.rn-realvideo"
      "video/x-matroska"
      "video/x-ms-asf"
      "video/x-msvideo"
      "video/x-ms-wmv"
      "video/x-ogm"
      "video/x-theora"
    ];
  };
in symlinkJoin {
  name = "syncplay-clever";
  paths = [
    desktopItems
    script
  ];

  meta = {
    homepage = "https://syncplay.pl/";
    description = "Free software that synchronises media players";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    maintainers = with lib.maintainers; [ assistant ];
  };
}