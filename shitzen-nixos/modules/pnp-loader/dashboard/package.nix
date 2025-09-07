{ lib
, buildNpmPackage
, requireFile
}:

buildNpmPackage {
  pname = "pnp-dashboard";
  version = "0.1.0";

  npmBuildScript = "build";

  npmDepsHash = "sha256-T8sBF2Sr9YX3GZTdHjjV3UQdj7bNM29+xOjA6FB4t7c=";

  src = requireFile {
    name = "pnp-panel.tar.gz";
    url = "file:///home/vali/pnp-panel.tar.gz";
    sha256 = "sha256-jS40fLyhpyau+dx1Kc8/woYOnqXJJmKj5ZBwIkOwqCA=";
  };

  installPhase = ''
    mkdir -p $out
    cp -r dist/* $out/
  '';
}
