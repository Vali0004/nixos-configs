{ lib
, buildNpmPackage
, fetchFromGitHub }:

buildNpmPackage {
  dontNpmBuild = true;
  name = "surfboard-hnap-exporter";
  npmDepsHash = "sha256-7wM/TLUc3b/cA64xNu4SQ1hWE9eTxPnHgiYujwpPK70=";
  src = ./src;
}