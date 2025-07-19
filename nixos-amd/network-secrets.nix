{ lib, ... }:

let
  privateFile = ./network-secrets-private.nix;
  secrets = {
    wifi = {
      ssid = "DummySSID";
      password = "DummyPassword";
    };
    zipline = {
      authorization = "dummy";
    };
  };
in
  if builtins.pathExists privateFile then
    lib.recursiveUpdate secrets (import privateFile)
  else
    secrets