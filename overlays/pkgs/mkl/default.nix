{
  lib,
  stdenv,
  callPackage,
  stdenvNoCC,
  fetchurl,
  rpmextract,
  validatePkgConfig,

  # Limits MKL_NUM_THREADS for downstream package checks.
  checkPhaseThreadLimitHook ? null,

  enableStatic ? stdenv.hostPlatform.isStatic,
}:

let
  mklVersion = "2025.3.1";
  mklStream = "2025.3";
  mklRel = "8";

  openmpVersion = "2025.3.3";
  openmpStream = "2025.3";
  openmpRel = "30";

  tbbVersion = "2022.3.1";
  tbbStream = "2022.3";
  tbbRel = "400";

  version = "${mklVersion}-${mklRel}";

  repo = "https://yum.repos.intel.com/oneapi";

  fetchRpm =
    {
      name,
      stream,
      version,
      release,
      arch ? "x86_64",
      hash ? lib.fakeHash,
    }:
    fetchurl {
      url = "${repo}/${name}-${stream}-${version}-${release}.${arch}.rpm";
      inherit hash;
    };

  # Base/core libraries used by both classic and SYCL interfaces.
  oneapi-mkl-core = fetchRpm {
    name = "intel-oneapi-mkl-core";
    stream = mklStream;
    version = mklVersion;
    release = mklRel;
    hash = "sha256-gTSZDJT86YEqIXU73PCg+1d07/LEA+bw67gGBLQw6F8=";
  };

  oneapi-mkl-core-devel = fetchRpm {
    name = "intel-oneapi-mkl-core-devel";
    stream = mklStream;
    version = mklVersion;
    release = mklRel;
    hash = "sha256-4J3a/vpljVAX5b+gUooyO4BeoRZnRgq/KwhWAAh6ByQ=";
  };

  # Traditional CPU BLAS/LAPACK interface and runtime.
  oneapi-mkl-classic = fetchRpm {
    name = "intel-oneapi-mkl-classic";
    stream = mklStream;
    version = mklVersion;
    release = mklRel;
    hash = "sha256-BQnmZtRlspDmDNG3/E7/o5lx6xsYol676GBtaLpOhoo=";
  };

  oneapi-mkl-classic-devel = fetchRpm {
    name = "intel-oneapi-mkl-classic-devel";
    stream = mklStream;
    version = mklVersion;
    release = mklRel;
    hash = "sha256-gbw3eXgy3dPZyj583MOvIdzrSCZCLeD3UMfmOJiDEX4=";
  };

  oneapi-mkl-classic-include = fetchRpm {
    name = "intel-oneapi-mkl-classic-include";
    stream = mklStream;
    version = mklVersion;
    release = mklRel;
    hash = "sha256-W9+SAleIS7/YKbrn1Ib1jfUVFwku/1n+lbDEkdAwA2I=";
  };

  # SYCL interface, CMake metadata, and headers.
  oneapi-mkl-sycl = fetchRpm {
    name = "intel-oneapi-mkl-sycl";
    stream = mklStream;
    version = mklVersion;
    release = mklRel;
    hash = "sha256-fEfK4UljjFhoIf9fzOhQ+ilIADqE78WelsN0xAiY/WM=";
  };

  oneapi-mkl-sycl-devel = fetchRpm {
    name = "intel-oneapi-mkl-sycl-devel";
    stream = mklStream;
    version = mklVersion;
    release = mklRel;
    hash = "sha256-mcAFhvANGdiGHJi5SHqUjo8KfBb4jK3c54V06fFIcS0=";
  };

  oneapi-mkl-sycl-include = fetchRpm {
    name = "intel-oneapi-mkl-sycl-include";
    stream = mklStream;
    version = mklVersion;
    release = mklRel;
    hash = "sha256-6MsuM9wi11k6cdsbD5AkNdWz+VHflgbYDGteVtIkH0s=";
  };

  # The domain library llama.cpp actually links through
  # MKL::MKL_SYCL::BLAS.
  oneapi-mkl-sycl-blas = fetchRpm {
    name = "intel-oneapi-mkl-sycl-blas";
    stream = mklStream;
    version = mklVersion;
    release = mklRel;
    hash = "sha256-l85MSBS3ZrXJAOPuzJMgj4bJe77sS5GzHHW0z+z8d60=";
  };

  oneapi-openmp = fetchRpm {
    name = "intel-oneapi-openmp";
    stream = openmpStream;
    version = openmpVersion;
    release = openmpRel;
    hash = "sha256-8+1KTEY5H0cPsodo26yozJRXJxTVNjY1NBWqLrYfPVM=";
  };

  oneapi-tbb = fetchRpm {
    name = "intel-oneapi-tbb";
    stream = tbbStream;
    version = tbbVersion;
    release = tbbRel;
    hash = "sha256-OELnyp9df9un6y8LGV+1O1RtXPa3oMRgvXEOyp9yeec=";
  };

  oneapi-mkl-sycl-lapack = fetchRpm {
    name = "intel-oneapi-mkl-sycl-lapack";
    stream = mklStream;
    version = mklVersion;
    release = mklRel;
    hash = "sha256-LA1l7jlcf4livF1l/KhEO/et8h31WichNUx3+Y2WiME=";
  };

  oneapi-mkl-sycl-sparse = fetchRpm {
    name = "intel-oneapi-mkl-sycl-sparse";
    stream = mklStream;
    version = mklVersion;
    release = mklRel;
    hash = "sha256-gO1+CDvyetGvjlCSJC9i5++QkdVDI3wug5aGetuSKjs=";
  };

  oneapi-mkl-sycl-dft = fetchRpm {
    name = "intel-oneapi-mkl-sycl-dft";
    stream = mklStream;
    version = mklVersion;
    release = mklRel;
    hash = "sha256-nHqQuxKHpK42VK1dc09cBMGrXUsCUYO3kedgHInth8U=";
  };

  oneapi-mkl-sycl-vm = fetchRpm {
    name = "intel-oneapi-mkl-sycl-vm";
    stream = mklStream;
    version = mklVersion;
    release = mklRel;
    hash = "sha256-fioA3a5Cffj5oeQqS9YELRmsfViiqYljAvT75UM7pMc=";
  };

  oneapi-mkl-sycl-rng = fetchRpm {
    name = "intel-oneapi-mkl-sycl-rng";
    stream = mklStream;
    version = mklVersion;
    release = mklRel;
    hash = "sha256-oSGj3XKlf0KErUXDgGjiPl3rDrzAbMnUxJ8GE0VR4Kk=";
  };

  oneapi-mkl-sycl-stats = fetchRpm {
    name = "intel-oneapi-mkl-sycl-stats";
    stream = mklStream;
    version = mklVersion;
    release = mklRel;
    hash = "sha256-yAMVFgvkK4obE2POG5wkcmbTuSjv1i27slwfZ+FYWO0=";
  };

  oneapi-mkl-sycl-data-fitting = fetchRpm {
    name = "intel-oneapi-mkl-sycl-data-fitting";
    stream = mklStream;
    version = mklVersion;
    release = mklRel;
    hash = "sha256-agZXT/TF6av5gjetzvhnmeZDFKWBG75Le5TJ0PWFVI4=";
  };

  rpmSources = [
    oneapi-mkl-core
    oneapi-mkl-core-devel

    oneapi-mkl-classic
    oneapi-mkl-classic-devel
    oneapi-mkl-classic-include

    oneapi-mkl-sycl
    oneapi-mkl-sycl-devel
    oneapi-mkl-sycl-include

    oneapi-mkl-sycl-blas
    oneapi-mkl-sycl-lapack
    oneapi-mkl-sycl-sparse
    oneapi-mkl-sycl-dft
    oneapi-mkl-sycl-vm
    oneapi-mkl-sycl-rng
    oneapi-mkl-sycl-stats
    oneapi-mkl-sycl-data-fitting

    oneapi-openmp
    oneapi-tbb
  ];

  shlibExt = stdenvNoCC.hostPlatform.extensions.sharedLibrary;
in
stdenvNoCC.mkDerivation {
  pname = "mkl";
  inherit version;

  strictDeps = true;
  dontUnpack = true;

  nativeBuildInputs = [
    rpmextract
    validatePkgConfig
  ];

  propagatedNativeBuildInputs =
    lib.optional
      (checkPhaseThreadLimitHook != null)
      checkPhaseThreadLimitHook;

  buildPhase = ''
    runHook preBuild

    extractRoot="$NIX_BUILD_TOP/extracted"
    mkdir -p "$extractRoot"

    for rpm in ${lib.concatStringsSep " " (map toString rpmSources)}; do
      (
        cd "$extractRoot"
        rpmextract "$rpm"
      )
    done

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    extractRoot="$NIX_BUILD_TOP/extracted"

    if [[ ! -d "$extractRoot" ]]; then
      echo "Extraction root missing: $extractRoot" >&2
      find "$NIX_BUILD_TOP" -maxdepth 3 -type d | sort >&2
      exit 1
    fi

    cd "$extractRoot"

    mklConfig="$(
      find opt/intel/oneapi/mkl \
        -path '*/lib/cmake/mkl/MKLConfig.cmake' \
        -print -quit
    )"

    if [[ -z "$mklConfig" ]]; then
      echo "MKLConfig.cmake was not found in the extracted RPMs" >&2
      find opt/intel/oneapi/mkl -maxdepth 5 -type f | sort >&2
      exit 1
    fi

    mklCmakeDir="$(dirname "$mklConfig")"
    mklRoot="$(realpath "$mklCmakeDir/../../..")"

    echo "Detected oneMKL root: $mklRoot"

    mkdir -p \
      "$out/include" \
      "$out/lib" \
      "$out/lib/cmake" \
      "$out/lib/pkgconfig" \
      "$out/share/doc/mkl"

    # Headers from the classic and SYCL include packages.
    if [[ -d "$mklRoot/include" ]]; then
      cp -a "$mklRoot/include/." "$out/include/"
    else
      echo "oneMKL include directory is missing: $mklRoot/include" >&2
      exit 1
    fi

    # All MKL shared libraries, including the SYCL BLAS domain.
    while IFS= read -r libDir; do
      cp -a "$libDir/." "$out/lib/"
    done < <(
      find "$mklRoot/lib" \
        -type f \
        \( \
          -name 'libmkl_core.so*' \
          -o -name 'libmkl_rt.so*' \
          -o -name 'libmkl_sycl_blas.so*' \
          -o -name 'libmkl_intel_lp64.so*' \
          -o -name 'libmkl_intel_ilp64.so*' \
          -o -name 'libmkl_sequential.so*' \
          -o -name 'libmkl_intel_thread.so*' \
          -o -name 'libmkl_tbb_thread.so*' \
        \) \
        -printf '%h\n' |
        sort -u
    )

    # Copy any remaining MKL shared libraries and symlinks. Some interface
    # libraries are referenced transitively by MKL's CMake targets.
    while IFS= read -r file; do
      cp -a "$file" "$out/lib/"
    done < <(
      find "$mklRoot/lib" \
        \( -type f -o -type l \) \
        -name 'libmkl*.so*'
    )

    # CMake configuration. Preserve the expected lib/cmake/mkl layout.
    cp -a "$mklCmakeDir" "$out/lib/cmake/mkl"

    # pkg-config metadata, when provided.
    while IFS= read -r file; do
      cp -a "$file" "$out/lib/pkgconfig/"
    done < <(
      find "$mklRoot" -type f -name 'mkl*.pc'
    )

    # Intel OpenMP runtime. Locate it rather than assuming the old
    # compiler/<version>/linux/compiler/lib/intel64_lin layout.
    while IFS= read -r file; do
      cp -a "$file" "$out/lib/"
    done < <(
      find opt/intel/oneapi/compiler \
        \( -type f -o -type l \) \
        \( \
          -name 'libiomp5.so*' \
          -o -name 'libiompstubs5.so*' \
        \)
    )

    # Intel oneTBB runtime.
    while IFS= read -r file; do
      cp -a "$file" "$out/lib/"
    done < <(
      find opt/intel/oneapi/tbb \
        \( -type f -o -type l \) \
        \( \
          -name 'libtbb.so*' \
          -o -name 'libtbbmalloc.so*' \
          -o -name 'libtbbmalloc_proxy.so*' \
          -o -name 'libtbbbind*.so*' \
        \)
    )

    # Rewrite CMake/pkg-config references away from the extracted /opt tree.
    while IFS= read -r file; do
      substituteInPlace "$file" \
        --replace-warn "$mklRoot" "$out" \
        --replace-warn 'lib/intel64' 'lib'
    done < <(
      find "$out/lib/cmake" "$out/lib/pkgconfig" \
        -type f \
        \( -name '*.cmake' -o -name '*.pc' \)
    )

    for f in "$out"/lib/pkgconfig/*.pc; do
      grep -q '^prefix=' "$f" || \
          sed -i "1iprefix=$out" "$f"
    done

    # License.
    licenseFile="$(
      find "$mklRoot" \
        -path '*/licensing/license.txt' \
        -print -quit
    )"

    if [[ -n "$licenseFile" ]]; then
      install -Dm0644 "$licenseFile" "$out/share/doc/mkl/license.txt"
    fi

    # Traditional BLAS/LAPACK compatibility names.
    if [[ -e "$out/lib/libmkl_rt${shlibExt}" ]]; then
      ln -s "libmkl_rt${shlibExt}" "$out/lib/libblas${shlibExt}"
      ln -s "libmkl_rt${shlibExt}" "$out/lib/libcblas${shlibExt}"
      ln -s "libmkl_rt${shlibExt}" "$out/lib/liblapack${shlibExt}"
      ln -s "libmkl_rt${shlibExt}" "$out/lib/liblapacke${shlibExt}"

      ln -s "libmkl_rt${shlibExt}" "$out/lib/libblas${shlibExt}.3"
      ln -s "libmkl_rt${shlibExt}" "$out/lib/libcblas${shlibExt}.3"
      ln -s "libmkl_rt${shlibExt}" "$out/lib/liblapack${shlibExt}.3"
      ln -s "libmkl_rt${shlibExt}" "$out/lib/liblapacke${shlibExt}.3"
    fi

    # Static libraries are provided by the devel RPMs when available.
    if ${lib.boolToString enableStatic}; then
      while IFS= read -r file; do
        cp -a "$file" "$out/lib/"
      done < <(
        find "$mklRoot/lib" -type f -name '*.a'
      )
    fi

    # Fail early if the pieces needed by llama.cpp were not packaged.
    test -e "$out/lib/libmkl_core.so"
    test -e "$out/lib/libmkl_sycl_blas.so"
    test -e "$out/lib/cmake/mkl/MKLConfig.cmake"

    runHook postInstall
  '';

  # Intel's license does not permit altering the distributed binaries.
  dontStrip = true;
  dontPatchELF = true;

  passthru.tests = {
    pkg-config-dynamic-iomp = callPackage ./test {
      enableStatic = false;
      execution = "iomp";
    };

    pkg-config-static-iomp = callPackage ./test {
      enableStatic = true;
      execution = "iomp";
    };

    pkg-config-dynamic-seq = callPackage ./test {
      enableStatic = false;
      execution = "seq";
    };

    pkg-config-static-seq = callPackage ./test {
      enableStatic = true;
      execution = "seq";
    };
  };

  meta = {
    description = "Intel oneAPI Math Kernel Library";
    longDescription = ''
      Intel oneAPI Math Kernel Library provides optimized mathematical
      routines for Intel processors and accelerators, including the oneMKL
      SYCL BLAS backend.
    '';
    homepage = "https://www.intel.com/content/www/us/en/developer/tools/oneapi/onemkl.html";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    license = lib.licenses.issl;
    platforms = [ "x86_64-linux" ];
  };
}