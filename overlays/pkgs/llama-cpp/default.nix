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
  effectiveStdenv =
    if cudaSupport then
      cudaPackages.backendStdenv
    else if syclSupport then
      intel-llvm.stdenv
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
  version = "10380";

  outputs = [
    "out"
    "dev"
  ];

  src = fetchFromGitHub {
    owner = "ggml-org";
    repo = "llama.cpp";
    tag = "b${finalAttrs.version}";
    hash = "sha256-iG3soqu8KY5L7CdGZVQTKN8Nd3MK+E7JsuJc8uj8pU4=";
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
    (cmakeBool "GGML_CUDA" cudaSupport)
    (cmakeBool "GGML_HIP" rocmSupport)
    (cmakeBool "GGML_METAL" metalSupport)
    (cmakeBool "GGML_RPC" rpcSupport)
    (cmakeBool "GGML_VULKAN" vulkanSupport)
    (cmakeBool "GGML_SYCL" syclSupport)
    (cmakeFeature "LLAMA_BUILD_NUMBER" finalAttrs.version)
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
  ++ optionals cudaSupport [
    (cmakeFeature "CMAKE_CUDA_ARCHITECTURES" cudaPackages.flags.cmakeCudaArchitecturesString)
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
    substituteInPlace ggml/src/ggml-sycl/element_wise.cpp \
      --replace-fail \
        '        constexpr int ver = __INTEL_LLVM_COMPILER;' \
        ""

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
EOF
  '';

  # upstream plans on adding targets at the cmakelevel, remove those
  # additional steps after that
  postInstall = ''
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
  NIX_LDFLAGS = lib.optionalString syclSupport "-L${onednn}/lib -lsvml -lirc -lintlc -limf";

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