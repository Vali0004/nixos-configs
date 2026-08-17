{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  libdrm,
  metrics-library,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "metrics-discovery";
  version = "1.14.182";

  src = fetchFromGitHub {
    owner = "intel";
    repo = "metrics-discovery";
    tag = "metrics-discovery-${finalAttrs.version}";
    hash = "sha256-AgrCJR10B1rtk/VLx7k5I3A4ZVhHoF3p4oxyiY4yAnI=";
  };

  nativeBuildInputs = [ cmake pkg-config ];

  buildInputs = [ libdrm metrics-library ];

  cmakeFlags = [
    (lib.cmakeFeature "CMAKE_POLICY_VERSION_MINIMUM" "3.5")
  ];

  meta = {
    description = "Intel Metrics Discovery API for GPU performance counters (libigdmd)";
    homepage = "https://github.com/intel/metrics-discovery";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
  };
})
