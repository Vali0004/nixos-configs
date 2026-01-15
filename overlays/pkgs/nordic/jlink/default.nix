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

let
  version = "V910";
  hash = "sha256-72vEBo1XDOVhA6F5LRH2c+oXMhhUbLwf5HIsX97JDS0";
in stdenv.mkDerivation {
  pname = "jlink";
  inherit version;

  src = requireFile {
    name = "JLink_Linux_${version}_x86_64.deb";
    url = "https://www.segger.com/downloads/jlink";
    inherit hash;
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
    cp -r opt/SEGGER/JLink_${version} $out/JLink

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