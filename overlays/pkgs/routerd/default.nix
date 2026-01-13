{ lib
, buildNpmPackage
, fetchFromGitHub }:

buildNpmPackage {
  dontNpmBuild = true;
  name = "routerd";
  npmDepsHash = "sha256-qJo0GdvRhLhHuBuczDgoQxAQ66bn+sscOD6SZ2y387k=";
  src = ./src;
}