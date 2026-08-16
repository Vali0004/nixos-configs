{
  lib,
  stdenvNoCC,
  fetchurl,
  rpmextract,
}:

# Intel's prebuilt oneDNN from the oneAPI RPM repo.
#
# nixpkgs' oneDNN is a CPU-only build (DNNL_GPU_RUNTIME=NONE), which is why
# llama-cpp here has historically been built with GGML_SYCL_DNN=false. Intel's
# distribution is compiled with:
#
#   DNNL_CPU_RUNTIME = SYCL
#   DNNL_GPU_RUNTIME = SYCL
#   DNNL_GPU_VENDOR  = INTEL
#
# which is what ggml-sycl requires: it compares DNNL_GPU_VENDOR against
# GGML_SYCL_TARGET and only links DNNL::dnnl when they match.
let
  stream = "2025.3";
  version = "2025.3.0";
  release = "409";

  repo = "https://yum.repos.intel.com/oneapi";

  fetchRpm =
    { name, hash }:
    fetchurl {
      url = "${repo}/${name}-${stream}-${version}-${release}.x86_64.rpm";
      inherit hash;
    };

  dnnl = fetchRpm {
    name = "intel-oneapi-dnnl";
    hash = "sha256-PLRc9VbxWRGrQUvG2cBT6X3vYuXgo5hzp4FJ9Kkn4U4=";
  };

  dnnl-devel = fetchRpm {
    name = "intel-oneapi-dnnl-devel";
    hash = "sha256-FqjVvBDyMf88J48AEqJcalKEw/nEfKhshqZK8REBV1k=";
  };

  # Intel builds libdnnl with icx, so it references the Intel compiler runtime
  # (_intel_fast_memset from libirc, __svml_* from libsvml). Nothing in nixpkgs
  # provides these, so ship them alongside or linking against dnnl fails.
  compiler-runtime = fetchurl {
    url = "${repo}/intel-oneapi-compiler-shared-runtime-2025.3-2025.3.3-30.x86_64.rpm";
    hash = "sha256-HFIGT4zLEQmBOnC8JhQ26pam9g8STRG3JSxSzIGr3qQ=";
  };
in
stdenvNoCC.mkDerivation {
  pname = "onednn-sycl";
  inherit version;

  strictDeps = true;
  dontUnpack = true;

  nativeBuildInputs = [ rpmextract ];

  buildPhase = ''
    runHook preBuild

    mkdir -p "$NIX_BUILD_TOP/extracted"
    for rpm in ${dnnl} ${dnnl-devel} ${compiler-runtime}; do
      ( cd "$NIX_BUILD_TOP/extracted" && rpmextract "$rpm" )
    done

    runHook postBuild
  '';

  # The bundled dnnl-config.cmake derives PACKAGE_PREFIX_DIR relative to
  # lib/cmake/dnnl, so preserving this layout needs no path rewriting.
  installPhase = ''
    runHook preInstall

    root="$NIX_BUILD_TOP/extracted/opt/intel/oneapi/dnnl/${stream}"
    test -d "$root" || { echo "unexpected RPM layout" >&2; ls -R "$NIX_BUILD_TOP/extracted" >&2; exit 1; }

    mkdir -p "$out"
    cp -a "$root/include" "$out/"
    cp -a "$root/lib" "$out/"
    if [ -d "$root/share" ]; then cp -a "$root/share" "$out/"; fi

    # Intel compiler runtime libraries required by libdnnl.
    crlib="$NIX_BUILD_TOP/extracted/opt/intel/oneapi/compiler/${stream}/lib"
    for l in libsvml libirc libintlc libimf; do
      find "$crlib" -maxdepth 1 \( -type f -o -type l \) -name "$l.so*" -exec cp -a {} "$out/lib/" \;
    done
    test -e "$out/lib/libsvml.so"
    test -e "$out/lib/libirc.so"

    # Fail loudly if the SYCL GPU build isn't what we got.
    grep -q '#define DNNL_GPU_RUNTIME DNNL_RUNTIME_SYCL' "$out/include/oneapi/dnnl/dnnl_config.h"
    grep -q '#define DNNL_GPU_VENDOR DNNL_VENDOR_INTEL' "$out/include/oneapi/dnnl/dnnl_config.h"
    test -e "$out/lib/cmake/dnnl/dnnl-config.cmake"

    runHook postInstall
  '';

  # Intel's license does not permit altering the distributed binaries.
  dontStrip = true;
  dontPatchELF = true;

  meta = {
    description = "Intel oneAPI Deep Neural Network Library (SYCL GPU build)";
    homepage = "https://github.com/uxlfoundation/oneDNN";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    license = lib.licenses.asl20;
    platforms = [ "x86_64-linux" ];
  };
}
