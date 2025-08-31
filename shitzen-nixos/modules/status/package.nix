{ lib
, buildNpmPackage
, fetchFromGitHub
}:

buildNpmPackage {
  dontNpmBuild = true;
  name = "fuckk-lol-status";
  npmDepsHash = "sha256-+/RupHRoOFqugGQm8RXg2NzOSYcJkr7de0spGx7aqFQ=";
  src = ./src;
}