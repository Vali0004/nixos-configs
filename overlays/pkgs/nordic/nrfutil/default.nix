{ python3Packages
, fetchFromGitHub }:

python3Packages.buildPythonApplication {
  pname = "adafruit-nrfutil";
  version = "unstable-2025-07-12";

  src = fetchFromGitHub {
    owner = "adafruit";
    repo = "Adafruit_nRF52_nrfutil";
    rev = "1361059009ff6a24d63b37eb3a4b28127837ead2";
    hash = "sha256-b3O6CMrfuK1HETC9wd2skNx7fA/4KS9fMjbpIaLN044=";
  };

  doCheck = false;

  format = "setuptools";

  propagatedBuildInputs = [
    python3Packages.pyserial
    python3Packages.click
    python3Packages.ecdsa
  ];
}