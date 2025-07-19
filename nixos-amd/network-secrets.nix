let
  privateFile = ./network-secrets-private.nix;
  secrets = {
    wifi = {
      ssid = "DummySSID";
      password = "DummyPassword";
    };
  };
in
  if builtins.pathExists privateFile then
    builtins.recursiveUpdate secrets (import privateFile)
  else
    secrets