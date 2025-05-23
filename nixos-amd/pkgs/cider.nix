{ pkgs, lib, ... }:

let
  name = "Cider";
  pname = "cider";
  version = "3.0.2";
  src = ./cider-v3.0.2-linux-x64.AppImage;
  appimageContents = pkgs.appimageTools.extractType2 {
    inherit pname src version;
  };
  cider3 = pkgs.appimageTools.wrapType2 rec {
    inherit name pname src version;

    extraInstallCommands =''
      mv $out/bin/${pname} $out/bin/${name}

      install -m 444 -D ${appimageContents}/${name}.desktop -t $out/share/applications
      substituteInPlace $out/share/applications/${name}.desktop \
        --replace 'Exec=AppRun' 'Exec=${name}'
      cp -r ${appimageContents}/usr/share/icons $out/share
    '';

    meta = with lib; {
      description = "A new look into listening and enjoying Apple Music in style and performance.";
      homepage = "https://cider.sh/";
      maintainers = [ ];
      platforms = [ "x86_64-linux" ];
    };
  };
in {
  environment.systemPackages = [ cider3 ];
}