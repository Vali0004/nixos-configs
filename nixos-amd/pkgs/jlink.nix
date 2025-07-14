{ pkgs, lib, ... }:

pkgs.stdenv.mkDerivation {
  pname = "jlink";
  version = "V818";
  src = ./JLink_Linux_V818_x86_64.deb;

  nativeBuildInputs = [
    pkgs.dpkg
    pkgs.autoPatchelfHook
  ];

  buildInputs = with pkgs; [
    zlib
    libusb1
    xorg.libX11
    xorg.libXrender
    xorg.libXrandr
    xorg.libXfixes
    xorg.libXcursor
    xorg.libSM
    xorg.libICE
    fontconfig
    freetype
    stdenv.cc.cc.lib # provides libstdc++.so.6 and libgcc_s.so.1
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