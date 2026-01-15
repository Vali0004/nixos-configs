{ lib
, buildNpmPackage
, fetchFromGitHub }:

buildNpmPackage {
  dontNpmBuild = true;
  name = "kursu-dev-status";
  npmDepsHash = "sha256-yXjHE5Z/P9LiEAWvCPVLFFbElGCuj/4tR9Gdf4kCe4o=";
  src = ./src;
}