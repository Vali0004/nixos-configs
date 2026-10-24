{ stdenv
, lib
, fetchurl
, autoPatchelfHook
, makeWrapper
, requireFile
, dpkg
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
, asar
, mesa
, nss
, nspr
, zlib }:

stdenv.mkDerivation (finalAttrs: {
  pname = "patreon-dl-gui";
  version = "2.10.3";

  src = requireFile {
    name = "patreon-dl-gui_2.10.3-cw3_amd64.deb";
    url = "file:///patreon-dl-gui_2.10.3-cw3_amd64.deb";
    sha256 = "sha256-0PZHZ79xMMe6UByQ3wA9nMTCaQ/NNatk0f8rV9VxDCg=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    dpkg
    asar
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
    runHook preUnpack

    mkdir unpacked
    cd unpacked
    dpkg-deb --fsys-tarfile "$src" | tar -xvf - \
      --no-same-owner \
      --no-same-permissions

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r usr/* $out/

    if [ -d etc ]; then
      mkdir -p $out/etc
      cp -r etc/* $out/etc/
    fi

    if [ ! -e $out/bin/patreon-dl-gui ] && [ -e $out/lib/patreon-dl-gui/patreon-dl-gui ]; then
      mkdir -p $out/bin
      ln -s $out/lib/patreon-dl-gui/patreon-dl-gui $out/bin/patreon-dl-gui
    fi

    asarfile="$out/lib/patreon-dl-gui/resources/app.asar"
    asardir="$TMPDIR/app.asar.unpack"

    mkdir -p "$asardir"
    asar extract "$asarfile" "$asardir"

    appjs="$asardir/.vite/build/index.js"

    substituteInPlace "$appjs" \
      --replace '"/bin/sh"' '"${bash}/bin/bash"' \
      --replace "'/bin/sh'" "'${bash}/bin/bash'" \
      --replace '"sh"' '"bash"' \
      --replace "'sh'" "'bash'"

    rm -f "$asarfile"
    asar pack "$asardir" "$asarfile"

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

    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/patreon-dl-gui \
      --prefix PATH : ${lib.makeBinPath [ bash coreutils ]} \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ mesa libGL libdrm ]} \
      --set SHELL ${bash}/bin/bash
  '';

  dontBuild = true;

  meta = with lib; {
    description = "GUI for patreon-dl";
    platforms = [ "x86_64-linux" ];
    mainProgram = "patreon-dl-gui";
  };
})