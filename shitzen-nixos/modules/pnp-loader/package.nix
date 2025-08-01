{ lib
, buildNpmPackage
}:

buildNpmPackage {
  dontNpmBuild = true;
  name = "pnp-loader";
  npmDepsHash = "sha256-yz1RY/E17CouQrpOOTAMnZlTusBa6o8NTXHy7N3pm+o=";
  src = ./src;
}
