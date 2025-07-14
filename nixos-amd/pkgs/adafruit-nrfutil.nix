{ pkgs, lib, ... }:

let
  nrfutil = pkgs.python3Packages.buildPythonApplication {
    pname = "adafruit-nrfutil";
    version = "unstable-2025-07-12";

    src = pkgs.fetchFromGitHub {
      owner = "adafruit";
      repo = "Adafruit_nRF52_nrfutil";
      rev = "1361059009ff6a24d63b37eb3a4b28127837ead2";
      hash = "sha256-b3O6CMrfuK1HETC9wd2skNx7fA/4KS9fMjbpIaLN044=";
    };

    # Required runtime dependencies listed in setup.py
    propagatedBuildInputs = with pkgs.python3Packages; [
      pyserial click ecdsa
    ];

    # Avoid tests if they fail or need network
    doCheck = false;

    # Ensure setuptools is used correctly
    format = "setuptools";
  };
in {
  environment.systemPackages = [ nrfutil ];
}