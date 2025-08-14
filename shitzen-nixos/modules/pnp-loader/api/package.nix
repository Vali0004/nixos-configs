{ lib
, buildNpmPackage
}:

buildNpmPackage {
  dontNpmBuild = true;
  pname = "pnp-api";
  version = "0.1.0";
  npmDepsHash = "sha256-u2TQ9TmuyjKLrPdyKXBs+taYOf97Rl63E1fh08jiYWw=";
  src = /home/vali/pnp-api;
}
