{ lib
, extractType2
, wrapType2 }:

let
  name = "OnTheSpot";
  pname = "onthespot";
  version = "1.1.2";
  src = ./OnTheSpot-1.1.2-x86_64.AppImage;
  appimageContents = extractType2 {
    inherit pname src version;
  };
in wrapType2 rec {
  inherit name pname src version;

  extraInstallCommands =''
    mv $out/bin/${pname} $out/bin/${name}

    install -m 444 -D ${appimageContents}/${name}.desktop -t $out/share/applications
    substituteInPlace $out/share/applications/${name}.desktop \
      --replace-warn 'Exec=AppRun' 'Exec=${name}'
    cp -r ${appimageContents}/usr/share/icons $out/share
  '';
}