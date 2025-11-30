{ stdenv
, lib
, fetchurl
, autoPatchelfHook
, makeWrapper
, alsa-lib
, bash
, bubblewrap
, coreutils
, dbus
, deno
, fontconfig
, freetype
, glib
, gtk3
, libdrm
, libgbm
, libGL
, libICE
, libSM
, libusb1
, libX11
# Backwards compat with 25.05
, xorg
, libxcomposite ? xorg.libXcomposite
, libxcursor ? xorg.libXcursor
, libxfixes ? xorg.libXfixes
, libxrandr ? xorg.libXrandr
, libxrender ? xorg.libXrender
, libxkbcommon
, mesa
, nss
, nspr
, zlib }:

stdenv.mkDerivation {
  pname = "patreon-dl-gui";
  version = "2.50.0";

  src = fetchurl rec {
    name = "patreon-dl-gui.tar.gz";
    url = "https://fuckk.lol/cdn/patreon-dl-gui.tar.gz";
    sha256 = "sha256-LfB3iCtOVdaFmYxYbEN0MYlhr94gvO+/KtZpyBOGg3I=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    alsa-lib
    bash
    dbus
    deno
    fontconfig
    freetype
    glib
    gtk3
    libdrm
    libgbm
    libGL
    libICE
    libSM
    libusb1
    libX11
    libxcomposite
    libxcursor
    libxfixes
    libxrandr
    libxrender
    libxkbcommon
    mesa
    nss
    nspr
    zlib
    stdenv.cc.cc.lib
  ];

  unpackPhase = ''
    tar -xvzf $src .
  '';

  installPhase = ''
    mkdir -p $out/bin $out/lib $out/share
    cp -r lib $out
    cp -r share/doc share/pixmaps $out/share/
    # Simlink the binary
    ln -s $out/lib/patreon-dl-gui/patreon-dl-gui $out/bin/patreon-dl-gui

    mkdir -p $out/share/applications
    cat > $out/share/applications/patreon-dl-gui.desktop <<EOF
    [Desktop Entry]
    Name=patreon-dl-gui
    Comment=GUI for patreon-dl
    Exec=$out/bin/patreon-dl-gui %U
    Icon=patreon-dl-gui
    Type=Application
    StartupNotify=true
    Categories=GNOME;GTK;Utility;
    EOF
  '';

  postFixup = ''
    wrapProgram $out/bin/patreon-dl-gui \
      --prefix LD_LIBRARY_PATH : ${mesa}/lib:${libGL}/lib:${libdrm}/lib \
      --set SHELL ${stdenv.shell}
  '';

  dontBuild = true;
}