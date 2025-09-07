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
    name = "pnp-api.tar.gz";
    url = "file:///home/vali/pnp-api.tar.gz";
    sha256 = "sha256-1B0soPkX16lzS86smAEq+pGaJwTltybIqzMXeimI+yg=";
  };
}
