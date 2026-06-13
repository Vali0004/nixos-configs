{ lib
, buildNpmPackage
, fetchFromGitHub }:

buildNpmPackage {
  dontNpmBuild = true;
  name = "searxng-mcp";
  npmDepsHash = "sha256-6SoXLxHI+qNTZe0+GrmfCG7ocWvVPPe7aXWMrftt630=";
  src = ./src;
}