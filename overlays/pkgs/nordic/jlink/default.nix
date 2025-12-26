{ stdenv
, lib
, requireFile
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
  version = "V896";

  src = requireFile {
    name = "JLink_Linux_V896_x86_64.deb";
    url = "https://www.segger.com/downloads/jlink";
    hash = "sha256-ijSqVfO64XNM0jS+1xxK92O5Tv7tiUQYm1rDpK+44Tc=";
  };

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
    cp -r opt/SEGGER/JLink_V866 $out/JLink

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