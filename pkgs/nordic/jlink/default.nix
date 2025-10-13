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
  version = "V866";

  src = requireFile {
    name = "JLink_Linux_V866_x86_64.deb";
    url = "https://www.segger.com/downloads/jlink";
    hash = "sha256-vL+GAZdJEUzR5jNglqcZE4tmeQLCSMb/Wk8uOYIAgCg=";
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