{ lib, buildNpmPackage, fetchFromGitHub, }:

buildNpmPackage (finalAttrs: {
  dontNpmBuild = true;
  name = "cors-anywhere";
  npmDepsHash = "sha256-S/3o3JyVSiXJTaG9uVHj4tlvPM8/sSb/xFaEK7SbeOQ=";
  src = fetchFromGitHub {
    owner = "Vali0004";
    repo = "cors-anywhere";
    rev = "c986587785d2039eccdc87e89d470b9315182b98";
    sha256 = "sha256-cYe0SX7JMOtUdEfe5FQsq3pFKY9y6+TwPKFdyQg3boE=";
  };
})