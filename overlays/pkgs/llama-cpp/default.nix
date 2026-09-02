{
  lib,
  autoAddDriverRunpath,
  cmake,
  fetchFromGitHub,
  installShellFiles,
  nix-update-script,
  stdenv,

  config,
  cudaSupport ? config.cudaSupport,
  cudaPackages ? { },

  rocmSupport ? config.rocmSupport,
  rocmPackages ? { },
  rocmGpuTargets ? rocmPackages.clr.localGpuTargets or rocmPackages.clr.gpuTargets,

  cpuArchDynamicDispatch ? !syclSupport,

  openclSupport ? false,
  clblast,

  syclSupport ? false,
  intel-llvm,
  level-zero,
  ocl-icd,
  mkl,
  onednn,
  tbb,

  blasSupport ? builtins.all (x: !x) [
    cudaSupport
    metalSupport
    openclSupport
    rocmSupport
    syclSupport
    vulkanSupport
  ],
  blas,

  fetchNpmDeps,
  nodejs_latest,
  npmHooks,

  pkg-config,
  metalSupport ? stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64 && !openclSupport,
  vulkanSupport ? false,
  rpcSupport ? false,
  openssl,
  llama-cpp,
  shaderc,
  vulkan-headers,
  vulkan-loader,
  spirv-headers,
  ninja,
}:

let
  # It's necessary to consistently use backendStdenv when building with CUDA support,
  # otherwise we get libstdc++ errors downstream.
  # cuda imposes an upper bound on the gcc version
  # NOTE: syclSupport is checked first on purpose - when both are on, the outer
  # build is the SYCL one and CUDA is delegated to the nested project. See
  # syclCudaSplit below.
  effectiveStdenv =
    if syclSupport then
      intel-llvm.stdenv
    else if cudaSupport then
      cudaPackages.backendStdenv
    else
      stdenv;
  inherit (lib)
    cmakeBool
    cmakeFeature
    optionals
    optionalString
    ;

  cudaBuildInputs = with cudaPackages; [
    cuda_cccl # <nv/target>

    # A temporary hack for reducing the closure size, remove once cudaPackages
    # have stopped using lndir: https://github.com/NixOS/nixpkgs/issues/271792
    cuda_cudart
    libcublas
  ];

  syclCudaSplit = syclSupport && cudaSupport;

  rocmBuildInputs = with rocmPackages; [
    clr
    hipblas
    rocblas
  ];

  syclBuildInputs = [
    level-zero
    ocl-icd
    mkl
    onednn
    tbb
  ];

  vulkanBuildInputs = [
    shaderc
    vulkan-headers
    vulkan-loader
  ];
in
effectiveStdenv.mkDerivation (finalAttrs: {
  pname = "llama-cpp";
  # Upstream switched from bNNNNN build tags to semver releases as of v0.1.0.
  # We track master rather than a release tag, so this is the version master
  # currently declares in CMakeLists.txt (LLAMA_VERSION_*) plus the pinned rev.
  version = "0.3.0-unstable-8e53fce";

  outputs = [
    "out"
    "dev"
  ];

  src = fetchFromGitHub {
    owner = "ggml-org";
    repo = "llama.cpp";
    rev = "8e53fcefd2c01ff70434ab41866bfc2eca31fe90";
    hash = "sha256-ZyZdHhmeut8z2Fv3S3UORjyHqM4K0E28icmvqIOCmq8=";
    #hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    leaveDotGit = true;
    postFetch = ''
      git -C "$out" rev-parse --short HEAD > $out/COMMIT
      find "$out" -name .git -print0 | xargs -0 rm -rf
    '';
  };

  patches = lib.optionals syclSupport [
    # bf16 support is gated on __INTEL_LLVM_COMPILER, which open-source
    # intel/llvm DPC++ does not define; without this, bf16 tensors (e.g. Qwen3.6
    # MTP heads) abort at runtime instead of failing at build time.
    ./0001-sycl-bf16-detect-by-header.patch
    # Skip oneDNN for small GEMMs on the f16 path, matching the existing f32
    # heuristic. ~+7% on MoE prompt processing at small batch.
    ./0002-sycl-f16-small-gemm-guard.patch
    # The reorder mmvq kernel re-derives each weight block's quant metadata
    # once per output column. Hoist the decode out of the column loop.
    ./0003-sycl-mmvq-reorder-decode-each-weight-block-once-no.patch
    # Collapse six identical reorder launchers into one, and make the workgroup
    # subgroup count tunable via GGML_SYCL_MMVQ_SUBGROUPS. No functional change.
    ./0004-sycl-mmvq-reorder-share-one-launcher-make-subgroup.patch
    # The mmvq -> oneDNN crossover is a CUDA-inherited constant of 8. Q4_K has
    # kernels instantiated past that and wins up to 11 on Battlemage (pp9 +25%).
    ./0005-sycl-mmvq-per-type-batch-crossover-Q4-K-to-11.patch
    # mmq is hardcoded off upstream ("accuracy issues"). Keep that default, but
    # allow opting in at runtime to re-measure on Xe2.
    ./0006-sycl-gate-mmq-re-enable-behind-GGML-SYCL-ENABLE-MM.patch
    # The q4_K vec-dot sums the q8_1 bytes with dp4a(0x01010101, ...). IGC
    # folds the multiply-by-ones away and emits 16 byte-extract mov + add3 per
    # output column instead - 24-35% of the kernel. quantize_q8_1 already
    # stores that sum in ds.y.
    ./0007-sycl-q4-K-mmvq-take-q8-1-block-sum-from-ds-y.patch
    # mmvq is flat at ~100 t/s from 9 to 16 columns while the dequant+oneDNN
    # fallback only climbs from 27 to 47, so 0005's cap of 11 left 2.1-2.6x on
    # the table for widths 12-16. Also fixes should_reorder_tensor, which gated
    # the one-shot weight reorder on a hardcoded ne[1] <= 8: any workload whose
    # first matmul was wider never reordered at all, and then ran every later
    # op on the slow layout (106 -> 36 t/s at pp16).
    ./0008-sycl-q4-K-mmvq-to-16-cols-and-fix-reorder-bootstrap.patch
    # 0005/0008 only ever moved the crossover for q4_K; every other type was
    # left on the CUDA-inherited 8 despite having the same fused kernels and
    # the same cliff-shaped fallback. Extend q3_K/q5_K/q6_K to 16 as well.
    ./0009-sycl-extend-mmvq-crossover-to-q3-K-q5-K-q6-K.patch
    # 0005/0008/0009 raised every k-quant but left q4_0/q8_0 on the CUDA
    # default of 8 - and q4_0 is the format that actually wants this. At 9
    # columns (MTP n-max 8, or a few parallel slots) it fell off mmvq into the
    # dequantise+oneDNN fallback: measured 44 -> 4.8 t/s.
    ./0010-sycl-extend-mmvq-crossover-to-q4-0-q8-0.patch
  ];

  nativeBuildInputs = [
    cmake
    installShellFiles
    ninja
    nodejs_latest
    npmHooks.npmConfigHook
    pkg-config
    spirv-headers
  ]
  ++ optionals cudaSupport [
    cudaPackages.cuda_nvcc
    autoAddDriverRunpath
  ];

  buildInputs =
    optionals cudaSupport cudaBuildInputs
    ++ optionals openclSupport [ clblast ]
    ++ optionals rocmSupport rocmBuildInputs
    ++ optionals syclSupport syclBuildInputs
    ++ optionals blasSupport [ blas ]
    ++ optionals vulkanSupport vulkanBuildInputs
    ++ [ openssl ];

  npmRoot = "tools/ui";
  npmDepsHash = "sha256-2Q7XhaLAArmviOLdQsNbYTfdyDE5pW9lR26cRHEVl9k=";
  #npmDepsHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  npmDeps = fetchNpmDeps {
    name = "${finalAttrs.pname}-${finalAttrs.version}-npm-deps";
    inherit (finalAttrs) src patches;
    preBuild = ''
      pushd ${finalAttrs.npmRoot}
    '';
    hash = finalAttrs.npmDepsHash;
  };

  preConfigure = ''
    prependToVar cmakeFlags "-DLLAMA_BUILD_COMMIT:STRING=$(cat COMMIT)"
    pushd ${finalAttrs.npmRoot}
    npm run build
    popd
  '';

  cmakeFlags = [
    (cmakeBool "GGML_NATIVE" false) # -march=native would make builds non-deterministic
    (cmakeBool "LLAMA_BUILD_EXAMPLES" false)
    (cmakeBool "LLAMA_BUILD_SERVER" true)
    (cmakeBool "LLAMA_BUILD_TESTS" (finalAttrs.finalPackage.doCheck or false))
    (cmakeBool "LLAMA_OPENSSL" true)
    (cmakeBool "BUILD_SHARED_LIBS" true)
    (cmakeBool "GGML_BLAS" blasSupport)
    (cmakeBool "GGML_CLBLAST" openclSupport)
    # In a split build the outer project must NOT enable CUDA - it would try to
    # drive nvcc with the DPC++ driver as host compiler. The nested project
    # below builds it instead.
    (cmakeBool "GGML_CUDA" (cudaSupport && !syclCudaSplit))
    (cmakeBool "GGML_HIP" rocmSupport)
    (cmakeBool "GGML_METAL" metalSupport)
    (cmakeBool "GGML_RPC" rpcSupport)
    (cmakeBool "GGML_VULKAN" vulkanSupport)
    (cmakeBool "GGML_SYCL" syclSupport)
    # NOT finalAttrs.version any more: build-info.cpp.in expands this into
    # `int LLAMA_BUILD_NUMBER = @LLAMA_BUILD_NUMBER@;`, so a semver string does
    # not compile. Upstream derives it from git describe, and postFetch strips
    # .git, so pin it to 0 and let the version show up via LLAMA_VERSION.
    (cmakeFeature "LLAMA_BUILD_NUMBER" "0")
    # Left at upstream's default (ON): we pin a master commit, not a release
    # tag, so the "-dev" suffix on the reported version is accurate.
  ]
  ++ optionals cpuArchDynamicDispatch [
    # Build all CPU backend variants for runtime dynamic dispatch.
    # This avoids illegal instructions on older CPUs and gives optimal performance
    # on newer ones without needing separate builds.
    # Enabling AVX2 can make CPU inference 13x faster compared to NixOS's x86_64 defaults.
    # Note it is not a bug that the CPU variant .so files are placed in `bin/`
    # (as opposed to `lib/`) alongside the executables by upstream's `CMakeLists.txt` design:
    # * https://github.com/ggml-org/llama.cpp/blob/b46812de78f8fbcb6cf0154947e8633ebc78d9ac/ggml/src/CMakeLists.txt#L249-L252
    # * https://github.com/ggml-org/llama.cpp/blob/b46812de78f8fbcb6cf0154947e8633ebc78d9ac/ggml/src/ggml-backend-reg.cpp#L480-L486
    (cmakeBool "GGML_CPU_ALL_VARIANTS" true)
    (cmakeBool "GGML_BACKEND_DL" true)
  ]
  ++ optionals (cudaSupport && !syclCudaSplit) [
    (cmakeFeature "CMAKE_CUDA_ARCHITECTURES" cudaPackages.flags.cmakeCudaArchitecturesString)
  ]
  ++ optionals syclCudaSplit [
    # Backends are dlopened from the install dir rather than linked in, which is
    # what lets a separately-compiled libggml-cuda.so join this build.
    (cmakeBool "GGML_BACKEND_DL" true)
    (cmakeBool "GGML_CUDA_EXTERNAL" true)
    (cmakeFeature "GGML_CUDA_EXTERNAL_CC" "${cudaPackages.backendStdenv.cc}/bin/gcc")
    (cmakeFeature "GGML_CUDA_EXTERNAL_CXX" "${cudaPackages.backendStdenv.cc}/bin/g++")
    (cmakeFeature "GGML_CUDA_EXTERNAL_ARCHS" cudaPackages.flags.cmakeCudaArchitecturesString)
  ]
  ++ optionals rocmSupport [
    (cmakeFeature "CMAKE_HIP_COMPILER" "${rocmPackages.clr.hipClangPath}/clang++")
    (cmakeFeature "CMAKE_HIP_ARCHITECTURES" (builtins.concatStringsSep ";" rocmGpuTargets))
  ]
  ++ optionals syclSupport [
    (cmakeBool "GGML_SYCL_F16" true)
    (cmakeFeature "GGML_SYCL_TARGET" "INTEL")
    # Intel's oneDNN (overlays/pkgs/onednn) is a SYCL GPU build, so ggml-sycl can
    # use its matmul + flash-attention paths instead of falling back to oneMKL.
    (cmakeBool "GGML_SYCL_DNN" true)
    (cmakeFeature "DNNL_DIR" "${onednn}/lib/cmake/dnnl")
    (cmakeBool "GGML_SYCL_SUPPORT_LEVEL_ZERO_API" true)

    (cmakeBool "DPCPP_COMPILER" true)
    (cmakeFeature "MKL_ROOT" "${mkl}")
    (cmakeFeature "MKL_DIR" "${mkl}/lib/cmake/mkl")
    (cmakeFeature "TBB_DIR" "${tbb}/lib/cmake/TBB")

    (cmakeFeature "LEVEL_ZERO_INCLUDE_DIR" "${level-zero}/include")
    (cmakeFeature "ZE_LOADER_LIB" "${level-zero}/lib/libze_loader.so")
  ]
  ++ optionals metalSupport [
    (cmakeFeature "CMAKE_C_FLAGS" "-D__ARM_FEATURE_DOTPROD=1")
    (cmakeBool "LLAMA_METAL_EMBED_LIBRARY" true)
  ]
  ++ optionals rpcSupport [
    # This is done so we can move rpc-server out of bin because llama.cpp doesn't
    # install rpc-server in their install target.
    (cmakeBool "CMAKE_SKIP_BUILD_RPATH" true)
  ];

  postPatch = lib.optionalString syclSupport ''
    substituteInPlace ggml/src/ggml-sycl/CMakeLists.txt \
      --replace-fail \
        'target_link_libraries(ggml-sycl PRIVATE MKL::MKL_SYCL::BLAS)' \
        'target_link_libraries(ggml-sycl PRIVATE
            ${mkl}/lib/libmkl_sycl.so
            ${mkl}/lib/libmkl_intel_ilp64.so
            ${mkl}/lib/libmkl_tbb_thread.so
            ${mkl}/lib/libmkl_core.so
            TBB::tbb
            sycl
            OpenCL
        )'

    cat > ggml/src/ggml-sycl/fortify-off.h <<'EOF'
#pragma once

#ifdef _FORTIFY_SOURCE
# undef _FORTIFY_SOURCE
#endif

#define _FORTIFY_SOURCE 0
EOF

    cat >> ggml/src/ggml-sycl/CMakeLists.txt <<'EOF'
target_compile_options(ggml-sycl PRIVATE
  -fno-sycl-rdc
  -include
  "''${CMAKE_CURRENT_SOURCE_DIR}/fortify-off.h"
)

target_link_options(ggml-sycl PRIVATE
  -fno-sycl-rdc
)

# Intel's libdnnl.so is compiled with icx and references the Intel compiler
# runtime (libirc/libsvml/libintlc/libimf) without recording DT_NEEDED entries
# for them, so they have to go on the link line explicitly. Scoped to this
# target on purpose: as derivation-wide NIX_LDFLAGS they also landed on the
# nested CUDA build, which then could not be dlopened.
target_link_libraries(ggml-sycl PRIVATE
  ${onednn}/lib/libsvml.so
  ${onednn}/lib/libirc.so
  ${onednn}/lib/libintlc.so.5
  ${onednn}/lib/libimf.so
)
EOF
  ''
  + lib.optionalString syclCudaSplit ''
    # Configuring ggml/ as its own top-level project sets GGML_STANDALONE, which
    # configure_file()s ggml.pc.in - a file the standalone ggml repo has but
    # llama.cpp's vendored copy does not. GGML_STANDALONE is a plain set(), not
    # a cache entry, so it cannot be turned off with -D; supply the file instead.
    cat > ggml/ggml.pc.in <<'EOF'
prefix=@CMAKE_INSTALL_PREFIX@
exec_prefix=''${prefix}
libdir=''${prefix}/@CMAKE_INSTALL_LIBDIR@
includedir=''${prefix}/@CMAKE_INSTALL_INCLUDEDIR@

Name: ggml
Description: The GGML Tensor Library for Machine Learning
Version: @GGML_INSTALL_VERSION@
Cflags: -I''${includedir}
Libs: -L''${libdir} -lggml
EOF

    cat >> ggml/src/CMakeLists.txt <<'EOF'
if (GGML_CUDA_EXTERNAL)
    include(ExternalProject)

    ExternalProject_Add(ggml-cuda-external
        SOURCE_DIR      "''${CMAKE_CURRENT_SOURCE_DIR}/.."
        PREFIX          "''${CMAKE_BINARY_DIR}/ggml-cuda-external"
        CMAKE_ARGS
            -DCMAKE_BUILD_TYPE=Release
            -DBUILD_SHARED_LIBS=ON
            -DGGML_BACKEND_DL=ON
            -DGGML_NATIVE=OFF
            -DGGML_CUDA=ON
            -DGGML_SYCL=OFF
            -DGGML_VULKAN=OFF
            -DGGML_BLAS=OFF
            -DGGML_OPENCL=OFF
            -DGGML_RPC=OFF
            -DGGML_CPU_ALL_VARIANTS=OFF
            # GGML_STANDALONE defaults these ON; we only want the CUDA backend.
            -DGGML_BUILD_TESTS=OFF
            -DGGML_BUILD_EXAMPLES=OFF
            -DCMAKE_C_COMPILER=''${GGML_CUDA_EXTERNAL_CC}
            -DCMAKE_CXX_COMPILER=''${GGML_CUDA_EXTERNAL_CXX}
            -DCMAKE_CUDA_HOST_COMPILER=''${GGML_CUDA_EXTERNAL_CXX}
            -DCMAKE_CUDA_ARCHITECTURES=''${GGML_CUDA_EXTERNAL_ARCHS}
        BUILD_BYPRODUCTS "<BINARY_DIR>/bin/libggml-cuda.so"
        INSTALL_COMMAND  ""
        USES_TERMINAL_CONFIGURE ON
        USES_TERMINAL_BUILD     ON
    )

    ExternalProject_Get_Property(ggml-cuda-external BINARY_DIR)

    # Force the nested build to finish before the outer one installs.
    add_dependencies(ggml ggml-cuda-external)

    # BINDIR, not LIBDIR: ggml_backend_load_all() searches the executable's own
    # directory, and with GGML_BACKEND_DL upstream installs every backend .so
    # next to the binaries. Putting this in lib/ builds fine and is never found.
    install(FILES "''${BINARY_DIR}/bin/libggml-cuda.so"
            DESTINATION ''${CMAKE_INSTALL_BINDIR})
endif()
EOF
  '';

  # upstream plans on adding targets at the cmakelevel, remove those
  # additional steps after that
  postInstall = lib.optionalString syclCudaSplit ''
    # Note which libstdc++ this points at: the default stdenv's gcc-15 one,
    # which is byte-for-byte the store path the executables and libggml-sycl.so
    # already resolve - NOT gcc-14's from cudaPackages.backendStdenv, even
    # though that is what compiled this file. Two libstdc++ in one process is
    # the ABI split this whole layout exists to avoid, and gcc-15's is a
    # superset, so it satisfies gcc-14-compiled code. Naming it explicitly
    # beats relying on it happening to be mapped before the dlopen.
    # libcuda.so.1 comes from the driver via autoAddDriverRunpath.
    patchelf --set-rpath "$out/bin:$out/lib:${stdenv.cc.cc.lib}/lib:${
      lib.makeLibraryPath cudaBuildInputs
    }" $out/bin/libggml-cuda.so
  ''
  + ''
    # Match previous binary name for this package
    ln -sf $out/bin/llama-cli $out/bin/llama

    mkdir -p $out/include
    cp $src/include/llama.h $out/include/

  ''
  + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform && !syclSupport) ''
    installShellCompletion --cmd llama-server --bash <($out/bin/llama-server --completion-bash)
  ''
  + optionalString rpcSupport "cp bin/rpc-server $out/bin/llama-rpc-server";

  # Intel's libdnnl.so is compiled with icx and references the Intel compiler
  # runtime (libirc/libsvml/libintlc) without recording DT_NEEDED entries for
  # them, so they have to be put on the link line explicitly.
  # Intel's compiler runtime for libdnnl is attached to the ggml-sycl target in
  # postPatch rather than here. NIX_LDFLAGS is derivation-wide, so in a split
  # build the nested CUDA project inherited it and linked libggml-cuda.so
  # against libsvml/libirc/libintlc/libimf - libraries it does not need and
  # cannot resolve at runtime, making its dlopen fail even with a working
  # driver. Clearing NIX_LDFLAGS for the nested build is not an option either:
  # it also carries the -L paths for cudadevrt/cudart_static.
  NIX_LDFLAGS = "";

  # the tests are failing as of 2025-08
  doCheck = false;

  passthru = {
    tests = lib.optionalAttrs stdenv.hostPlatform.isDarwin {
      metal = llama-cpp.override { metalSupport = true; };
    };
    updateScript = nix-update-script {
      attrPath = "llama-cpp";
      extraArgs = [
        "--version-regex"
        "b(.*)"
      ];
    };
  };

  meta = {
    description = "Inference of Meta's LLaMA model (and others) in pure C/C++";
    homepage = "https://github.com/ggml-org/llama.cpp";
    license = lib.licenses.mit;
    mainProgram = "llama";
    maintainers = with lib.maintainers; [
      booxter
      philiptaron
      xddxdd
      yuannan
    ];
    platforms = lib.platforms.unix;
    badPlatforms = optionals (cudaSupport || openclSupport || syclSupport) lib.platforms.darwin;
    broken = (metalSupport && !effectiveStdenv.hostPlatform.isDarwin) || (syclSupport && !effectiveStdenv.hostPlatform.isLinux);
  };
})