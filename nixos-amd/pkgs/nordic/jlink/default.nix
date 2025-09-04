{ stdenv
, lib
, autoPatchelfHook
, dpkg
, fontconfig
, freetype
, libICE
, libSM
, libusb1
, libX11
, libXcursor
, libXfixes
, libXrandr
, libXrender
, zlib }:

stdenv.mkDerivation {
  pname = "jlink";
  version = "V818";

  src = ./JLink_Linux_V818_x86_64.deb;

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
  ];

  buildInputs = [
    fontconfig
    freetype
    libICE
    libSM
    libusb1
    libX11
    libXcursor
    libXfixes
    libXrandr
    libXrender
    zlib
    stdenv.cc.cc.lib
  ];

  unpackPhase = ''
    dpkg-deb -x $src .
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp -r opt/SEGGER/JLink_V818 $out/JLink

    # Symlink all executables
    for f in $out/JLink/*; do
      if [ -x "$f" ] && [ ! -d "$f" ]; then
        ln -s "$f" "$out/bin/$(basename "$f")"
      fi
    done
  '';

  dontBuild = true;

  meta = with lib; {
    description = "SEGGER J-Link Tools";
    homepage = "https://www.segger.com/downloads/jlink/";
    license = licenses.unfreeRedistributable;
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
  };
}