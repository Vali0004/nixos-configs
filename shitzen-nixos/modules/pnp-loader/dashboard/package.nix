{ lib
, buildNpmPackage
}:

buildNpmPackage {
  pname = "pnp-dashboard";
  version = "0.1.0";

  src = /home/vali/pnp-panel;

  npmDepsHash = "sha256-T8sBF2Sr9YX3GZTdHjjV3UQdj7bNM29+xOjA6FB4t7c=";

  npmBuildScript = "build";

  installPhase = ''
    mkdir -p $out
    cp -r dist/* $out/
  '';
}
