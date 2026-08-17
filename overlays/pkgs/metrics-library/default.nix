{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  libdrm,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "metrics-library";
  version = "1.0.200";

  src = fetchFromGitHub {
    owner = "intel";
    repo = "metrics-library";
    tag = "metrics-library-${finalAttrs.version}";
    hash = "sha256-G/9uJFNwPThxFs96jPoI+4Po1Enk/nOfTTcOtLHnSps=";
  };

  nativeBuildInputs = [ cmake pkg-config ];

  buildInputs = [ libdrm ];

  cmakeFlags = [
    (lib.cmakeFeature "CMAKE_POLICY_VERSION_MINIMUM" "3.5")
  ];

  meta = {
    description = "Intel Metrics Library for MDAPI (libigdml)";
    homepage = "https://github.com/intel/metrics-library";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
  };
})
