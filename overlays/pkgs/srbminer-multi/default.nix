{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, makeWrapper
, ocl-icd
}:

stdenv.mkDerivation rec {
  pname = "srbminer-multi";
  version = "3.4.1";

  src = fetchurl {
    url = "https://github.com/doktor83/SRBMiner-Multi/releases/download/${version}/SRBMiner-Multi-${builtins.replaceStrings ["."] ["-"] version}-Linux.tar.gz";
    hash = "sha256-wt5tqHr61tU2VzCEpGz7COK9WzjNv5JFGZ0JOm6mlw8=";
  };

  nativeBuildInputs = [ autoPatchelfHook makeWrapper ];
  buildInputs = [ ocl-icd ];

  # SRBMiner ships its own bundled libs; tell autoPatchelf to find them too
  autoPatchelfIgnoreMissingDeps = true;

  sourceRoot = "SRBMiner-Multi-${builtins.replaceStrings ["."] ["-"] version}";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/srbminer-multi
    cp -r * $out/share/srbminer-multi/

    makeWrapper "${stdenv.cc.libc}/lib/ld-linux-x86-64.so.2" $out/bin/srbminer-multi \
      --add-flags "$out/share/srbminer-multi/SRBMiner-MULTI" \
      --run "cd $out/share/srbminer-multi" \
      --set LD_LIBRARY_PATH "${lib.makeLibraryPath [ ocl-icd stdenv.cc.cc.lib ]}"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Multi-algorithm CPU and GPU miner (closed source)";
    homepage = "https://github.com/doktor83/SRBMiner-Multi";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "srbminer-multi";
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}