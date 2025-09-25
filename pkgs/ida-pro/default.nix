{ pkgs
, lib
, autoPatchelfHook
, copyDesktopItems
, callPackage
, makeDesktopItem
, makeWrapper
, requireFile
, stdenv
, cairo
, curl
, dbus
, fontconfig
, freetype
, glib
, gtk3
# Needed for upg32
, ncurses
, libdrm
, libGL
, libkrb5
, libICE
, libsecret
, libSM
, libunwind
, libX11
, libXau
, libxcb
, libXcursor
, libXext
, libXi
, libxkbcommon
, libXrender
, openssl
, python313
, qt5
, libsForQt5
, xcbutilimage
, xcbutilkeysyms
, xcbutilrenderutil
, xcbutilwm
, zlib
}:

let
  pythonForIDA = pkgs.python313.withPackages (ps: with ps; [ rpyc ]);
  libida = pkgs.callPackage ./crack.nix {};
in stdenv.mkDerivation rec {
  pname = "ida-pro";
  version = "9.1.0.250226";

  src = requireFile {
    name = "ida-pro_91_x64linux.run";
    url = "file:///ida-pro_91_x64linux.run";
    sha256 = "sha256-j/CAIr46DvaTqePqAQENE1aybP3Lvn/daNAbPJcA+eI=";
  };

  desktopItem = makeDesktopItem {
    name = "ida-pro";
    exec = "ida";
    icon = ./appico.png;
    comment = meta.description;
    desktopName = "IDA Pro";
    genericName = "Interactive Disassembler";
    categories = [ "Development" ];
    startupWMClass = "IDA";
  };

  desktopItems = [
    (makeDesktopItem {
      name = "ida-pro";
      exec = "ida";
      icon = ./appico.png;
      comment = meta.description;
      desktopName = "IDA Pro";
      genericName = "Interactive Disassembler";
      categories = [ "Development" ];
      startupWMClass = "IDA";
    })
    (makeDesktopItem {
      name = "ida-pro-cli";
      exec = "idat";
      icon = ./appico.png;
      comment = meta.description;
      desktopName = "IDA NCurses";
      genericName = "Interactive Disassembler";
      categories = [ "Development" ];
    })
    (makeDesktopItem {
      name = "hexrays-viewer";
      exec = "hv";
      comment = meta.description;
      desktopName = "Hex-Rays Viewer";
      categories = [ "Development" ];
    })
    (makeDesktopItem {
      name = "hexrays-viewer-ui";
      exec = "hvui";
      comment = meta.description;
      desktopName = "Hex-Rays Viewer GUI";
      categories = [ "Development" ];
    })
  ];

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
    makeWrapper
    qt5.wrapQtAppsHook
  ];

  # We just get a runfile in $src, so no need to unpack it.
  dontUnpack = true;

  # Add everything to the RPATH, in case IDA decides to dlopen things.
  runtimeDependencies = [
    cairo
    curl.out
    dbus
    fontconfig
    freetype
    glib
    gtk3
    libdrm
    libGL
    libICE
    libSM
    libida
    libkrb5
    libunwind
    libX11
    libXau
    libxcb
    libXext
    libXi
    libxkbcommon
    libXrender
    libsecret
    ncurses
    openssl.out
    pythonForIDA
    libsForQt5.qtbase
    libsForQt5.qttools
    stdenv.cc.cc
    xcbutilimage
    xcbutilkeysyms
    xcbutilrenderutil
    xcbutilwm
    zlib
  ];
  buildInputs = runtimeDependencies;

  dontWrapQtApps = true;

  installPhase = ''
    runHook preInstall

    function print_debug_info() {
      if [ -f installbuilder_installer.log ]; then
        cat installbuilder_installer.log
      else
        echo "No debug information available."
      fi
    }

    trap print_debug_info EXIT

    mkdir -p $out/bin $out/lib $out/opt/.local/share/applications

    # IDA depends on quite some things extracted by the runfile, so first extract everything
    # into $out/opt, then remove the unnecessary files and directories.
    IDADIR="$out/opt"
    # IDA doesn't always honor `--prefix`, so we need to hack and set $HOME here.
    HOME="$out/opt"

    # Invoke the installer with the dynamic loader directly, avoiding the need
    # to copy it to fix permissions and patch the executable.
    $(cat $NIX_CC/nix-support/dynamic-linker) $src \
      --mode unattended --debuglevel 4 --prefix $IDADIR

    # Copy libida from a custom source
    cp ${libida}/opt/* $IDADIR

    # Link the exported libraries to the output.
    for lib in $IDADIR/libida*; do
      ln -s $lib $out/lib/$(basename $lib)
    done

    # Manually patch libraries that dlopen stuff.
    patchelf --add-needed libpython3.13.so $out/lib/libida.so
    patchelf --add-needed libcrypto.so $out/lib/libida.so

    # Fix libncurses
    ln -s ${ncurses}/lib/libncurses.so $IDADIR/libncurses.so
    ln -s $IDADIR/libncurses.so $out/lib/libncurses.so
    ln -s $IDADIR/libncurses.so $out/lib/libcurses.so
    # Fix TVision
    patchelf --add-needed libncurses.so $IDADIR/libtvision.so
    ln -s $IDADIR/libtvision.so $out/lib/libtvision.so

    # Cleanup unneeded/unfunctional files
    rm $IDADIR/'Uninstall IDA Professional 9.1.desktop'
    rm $IDADIR/uninstall $IDADIR/uninstall.dat

    # Allow for overrides to qt
    rm $IDADIR/qt.conf

    # Some libraries come with the installer.
    addAutoPatchelfSearchPath $IDADIR

    # Link the binaries to the output.
    # Also, hack the PATH so that pythonForIDA is used over the system python.
    for bb in ida idat assistant hv hvui upg32; do
      wrapProgram $IDADIR/$bb \
        --prefix PYTHONPATH : $IDADIR/idalib/python \
        --prefix PATH : ${pythonForIDA}/bin \
        --prefix LD_LIBRARY_PATH : ${libsForQt5.qtbase}/lib:${libsForQt5.qttools}/lib
      ln -s $IDADIR/.$bb-wrapped $out/bin/$bb
    done

    mv $IDADIR/themes/default $IDADIR/themes/light
    mv $IDADIR/themes/dark $IDADIR/themes/default

    ln -s $IDADIR/plugins/platforms $IDADIR/platforms

    runHook postInstall
  '';

  meta = with lib; {
    description = "The world's smartest and most feature-full disassembler";
    homepage = "https://hex-rays.com/ida-pro/";
    license = licenses.unfree;
    mainProgram = "ida";
    maintainers = with maintainers; [ msanft ];
    platforms = [ "x86_64-linux" ]; # Right now, the installation script only supports Linux.
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
}