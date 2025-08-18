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
    name = "pnp-panel.tar.xz";
    url = "file:///home/vali/pnp-panel.tar.xz";
    sha256 = "sha256-IWh/x0i1VwFAY7TgEbAYR/Y0Ry9ORkluQHBu2VZEr78=";
  };

  installPhase = ''
    mkdir -p $out
    cp -r dist/* $out/
  '';
}
