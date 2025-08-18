{ lib
, buildNpmPackage
, requireFile
}:

buildNpmPackage {
  dontNpmBuild = true;
  pname = "pnp-api";
  version = "0.1.0";
  npmDepsHash = "sha256-u2TQ9TmuyjKLrPdyKXBs+taYOf97Rl63E1fh08jiYWw=";
  src = requireFile {
    name = "pnp-api.tar.xz";
    url = "file:///home/vali/pnp-api.tar.xz";
    sha256 = "sha256-zVoomaUxPXi4NpsPMDsloiWh+QDnlHh2COfb3XXjkow=";
  };
}
