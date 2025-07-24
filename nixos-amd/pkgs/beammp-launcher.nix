{ stdenv
, lib
, copyDesktopItems
, fetchFromGitHub
, installShellFiles
, makeDesktopItem
, boost
, cmake
, curl
, httplib
, nlohmann_json
, openssl
, pkg-config
, zlib
}:

stdenv.mkDerivation {
  name = "beammp-launcher";
  version = "2.5.1";

  src = fetchFromGitHub {
    owner = "Vali0004";
    repo = "BeamMP-Launcher";
    rev = "9c6f97fc46022240caa421afafc9a39c67f628b3";
    hash = "sha256-VMNVa5wFIdYWRG1ljAR8FDCn/a7mHQRYHNLgKxnAuZg=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    copyDesktopItems
    installShellFiles
  ];

  buildInputs = [
    boost
    httplib
    openssl
    nlohmann_json
    curl
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "beammp-launcher";
      exec = "steam-run BeamMP-Launcher";
      desktopName = "BeamMP-Launcher";
      comment = "Launcher for the BeamMP mod for BeamNG.drive";
      categories = [ "Game" ];
      terminal = true;
    })
  ];

  installPhase = ''
    runHook preInstall

    installBin BeamMP-Launcher

    runHook postInstall
  '';

  meta = {
    description = "Launcher for the BeamMP mod for BeamNG.drive";
    homepage = "https://github.com/BeamMP/BeamMP-Launcher";
    mainProgram = "BeamMP-Launcher";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [  ];
    platforms = lib.platforms.linux;
  };
}