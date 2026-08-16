{ lib
, stdenvNoCC
, fetchFromGitHub
, makeWrapper
, python3
, ffmpeg
}:

let
  tinyec = python3.pkgs.buildPythonPackage rec {
    pname = "tinyec";
    version = "0.4.0";
    format = "setuptools";

    src = python3.pkgs.fetchPypi {
      inherit pname version;
      hash = "sha256-sDZKqzua9jK2TyTq+uDI5WzGS0hFZIdSYQ9I8qsFR6M=";
    };

    doCheck = false;
    pythonImportsCheck = [ "tinyec" ];

    meta = {
      description = "Tiny library to perform arithmetic operations on elliptic curves";
      homepage = "https://github.com/alexmgr/tinyec";
      license = lib.licenses.gpl3Only;
    };
  };

  pythonEnv = python3.withPackages (ps: with ps; [
    click
    crcmod
    flask
    flask-sock
    ifaddr
    paho-mqtt
    platformdirs
    pycryptodomex
    python-dotenv
    requests
    rich
    tqdm
    tinyec
  ]);
in
stdenvNoCC.mkDerivation {
  pname = "ankerctl";
  version = "0-unstable-2026-05-20";

  src = fetchFromGitHub {
    owner = "neekolascmd";
    repo = "ankermake-m5-protocol";
    rev = "c23b48bc88fcc52f1f28488dd483c7bb6ff86100";
    hash = "sha256-/PjE+oH2BNrbxAj+4w2zFopi1dhwdnLEDYGFQEi6cME=";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontConfigure = true;
  dontBuild = true;

  # web/__init__.py builds its Flask root_path from libflagship's ROOT_DIR
  # (__file__/../..), so the whole tree has to stay laid out as in the repo.
  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/ankerctl
    cp -r ankerctl.py cli libflagship web static $out/share/ankerctl/

    makeWrapper ${pythonEnv}/bin/python $out/bin/ankerctl \
      --add-flags $out/share/ankerctl/ankerctl.py \
      --prefix PATH : ${lib.makeBinPath [ ffmpeg ]}

    runHook postInstall
  '';

  meta = {
    description = "CLI and web UI for monitoring and controlling AnkerMake M5/M5C printers";
    homepage = "https://github.com/Ankermgmt/ankermake-m5-protocol";
    downloadPage = "https://github.com/neekolascmd/ankermake-m5-protocol";
    license = lib.licenses.gpl3Only;
    mainProgram = "ankerctl";
    platforms = lib.platforms.linux;
  };
}
