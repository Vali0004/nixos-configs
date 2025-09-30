{ lib, ... }:

let
  privateFile = ./network-secrets-private.nix;

  defaultSecrets = {
    wifi = {
      ssid = "DummySSID";
      password = "DummyPassword";
    };
    zipline = {
      authorization = "dummy";
    };
  };

  privateSecrets =
    if builtins.pathExists privateFile then import privateFile else { };

  mergedSecrets = lib.recursiveUpdate defaultSecrets privateSecrets;
in {
  options.secrets = lib.mkOption {
    type = lib.types.attrs;
    description = "System secrets (for config options)";
    default = mergedSecrets;
    readOnly = true;
  };
}