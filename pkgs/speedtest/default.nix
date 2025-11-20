{ stdenv
, lib
, fetchurl }:


stdenv.mkDerivation {
  name = "speedtest";

  src = fetchurl {
    url = "https://fuckk.lol/cdn/speedtest.tar.gz";
    sha256 = "sha256-c21A6R0JEBj7j4NV1kJPtPPaBcKNv22unsRk9RAHRXw=";
  };

  installPhase = ''
    mkdir -p $out/bin $out/doc
    cp speedtest $out/bin/
    cp speedtest.5 speedtest.md $out/doc/
  '';

  dontBuild = true;
}
