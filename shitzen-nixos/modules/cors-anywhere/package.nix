{ lib, buildNpmPackage, fetchFromGitHub, }:

buildNpmPackage (finalAttrs: {
  dontNpmBuild = true;
  name = "cors-anywhere";
  npmDepsHash = "sha256-awaVLywKQBVvSi8k5bzZvZLdnzOg/EsXdANOYg93ZHE=";
  postPatch = ''
    ln -s ${./package-lock.json} package-lock.json
  '';
  src = fetchFromGitHub {
    owner = "Rob--W";
    repo = "cors-anywhere";
    rev = "70aaa22b3f9ad30c8566024bf25484fd1ed9bda9";
    sha256 = "sha256-Nf6TJPRyTH9/mlVfcnmlmUhNDEVIz3/00I/fWb7Zb34=";
  };
})