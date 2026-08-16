{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

# Intel MEI (Management Engine Interface) transport library. Only needed here as
# a dependency of igsc, which xpu-smi links for GPU firmware queries.
stdenv.mkDerivation (finalAttrs: {
  pname = "metee";
  version = "6.2.5";

  src = fetchFromGitHub {
    owner = "intel";
    repo = "metee";
    tag = finalAttrs.version;
    hash = "sha256-ecI6XmIM3VK9+xcbvc5mB22Yg0f/mcUwNpFtJSoP4Gk=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_SHARED_LIBS" true)
    (lib.cmakeBool "BUILD_TEST" false)
    (lib.cmakeBool "BUILD_SAMPLES" false)
  ];

  meta = {
    description = "Intel MEI library (cross-platform access to the Management Engine interface)";
    homepage = "https://github.com/intel/metee";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux;
  };
})
