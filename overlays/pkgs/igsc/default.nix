{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  metee,
  systemdLibs,
}:

# Intel Graphics System Controller firmware update library. xpu-smi links this
# to report GPU firmware versions.
stdenv.mkDerivation (finalAttrs: {
  pname = "igsc";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "intel";
    repo = "igsc";
    tag = "V${finalAttrs.version}";
    hash = "sha256-NSNLiUMJBGtnfWUDIPIukyjgcI1YX9cfDDWphW8uSWs=";
  };

  nativeBuildInputs = [ cmake pkg-config ];
  buildInputs = [ metee systemdLibs ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_SHARED_LIBS" true)
    (lib.cmakeBool "ENABLE_WERROR" false)
    (lib.cmakeBool "BUILD_TESTS" false)
    (lib.cmakeBool "BUILD_SAMPLES" false)
  ];

  meta = {
    description = "Intel Graphics System Controller firmware update library";
    homepage = "https://github.com/intel/igsc";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux;
  };
})
