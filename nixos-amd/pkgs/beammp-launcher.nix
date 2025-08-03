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
    owner = "BeamMP";
    repo = "BeamMP-Launcher";
    rev = "5b2eb0a1a0a9318303ca9fc7dda7bcad2d00c778";
    hash = "sha256-GXhEoMhHqaZ5e3VMA/cmFqFBCVoTUay/Nq+oLWhihnc=";
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