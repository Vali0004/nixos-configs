{ stdenv
, pkgs
, autoPatchelfHook
, installShellFiles
, pkg-config
, alsa-lib
, libGL
, glib
, gtk3
, libdrm
, libgbm
, libX11
, libXcursor
, libXi
, libXinerama
, libXrandr
, libXrender
, nspr
, nss
, zlib
, ...
}:

stdenv.mkDerivation {
  pname = "beamng";
  version = "0.1";

  src = builtins.path {
    path = /home/vali/.local/share/Steam/steamapps/common/BeamNG.drive/BinLinux;
    name = "beamng";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    pkg-config
    installShellFiles
  ];

  buildInputs = [
    nss
    nspr
    alsa-lib
    libGL
    zlib
    glib
    gtk3
    libdrm
    libgbm
    pkgs.xorg.libX11
    pkgs.xorg.libXcursor
    pkgs.xorg.libXrandr
    pkgs.xorg.libXinerama
    pkgs.xorg.libXi
    pkgs.xorg.libXrender
  ];

  installPhase = ''
    mkdir -p $out/bin $out/lib
    cp $src/*.so $out/lib/
    cp $src/*.so.* $out/lib/

    installBin BeamNG.drive.x64
  '';

  dontBuild = true;
}