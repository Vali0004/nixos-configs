{ appimageTools
, fetchurl
, makeWrapper
, lib
, callPackage
# jlink deps
, stdenv
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
, zlib
}:

let
  pname = "nrfconnect";
  version = "5.2.0";
  src = fetchurl {
    url = "https://eu.files.nordicsemi.com/ui/api/v1/download?repoKey=web-assets-com_nordicsemi&path=external%2fswtools%2fncd%2flauncher%2fv5.2.0%2fnrfconnect-5.2.0-x86_64.AppImage";
    hash = "sha256-Y42cxK44tFYFj7TFpe+rmSWTo0v5+u9VjG37SCGvmws=";
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };

  jlink = callPackage ./jlink {};
in appimageTools.wrapType2 {
  inherit pname version src;

  nativeBuildInputs = [
    makeWrapper
  ];

  extraBwrapArgs = [
    "--ro-bind" "${jlink}/JLink" "/opt/SEGGER/JLink"
  ];

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/${pname}.desktop -t $out/share/applications
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace-warn 'Exec=AppRun' 'Exec=${pname}'
    cp -r ${appimageContents}/usr/share/icons $out/share
  '';

  meta = with lib; {
    description = "Cross-platform development software for Nordic Products";
    homepage = "https://www.nordicsemi.com/Products/Development-tools/nRF-Connect-for-Desktop";
    platforms = [ "x86_64-linux" ];
    maintainers = [ ];
  };
}