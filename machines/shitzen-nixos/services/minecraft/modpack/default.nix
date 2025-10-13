{ stdenv
, lib
, requireFile
, fetchurl
, writeText
, runCommand }:

let
  overrides = import ./overrides.nix { inherit fetchurl writeText; };

  overridesTree = runCommand "overrides" {} ''
    mkdir -p $out
    ${lib.concatStringsSep "\n" (lib.mapAttrsToList (path: src:
      ''
        mkdir -p $out/$(dirname ${path})
        cp -r ${src} $out/${path}
      ''
    ) overrides)}
  '';
in
stdenv.mkDerivation {
  pname = "BetterMC";
  version = "3.6";

  src = requireFile {
    name = "better-mc.tar.gz";
    url = "file:///better-mc.tar.gz";
    sha256 = "sha256-dme1k0cTO+AHevZLZj8Rx77uPEOd3fUefBe171ZfrXI=";
  };

  installPhase = ''
    mkdir -p $out
    cp -r config defaultconfigs modernfix mods $out
    cp -r ${overridesTree}/* $out/
  '';

  dontBuild = true;
}
