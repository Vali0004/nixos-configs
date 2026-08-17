{
  lib,
  fetchFromGitHub,
  python3Packages,
  intel-llvm,
  level-zero,
  mkl,
  onednn,

  gpuTargets ? [ ],
}:

let
  torch-xpu-ops = fetchFromGitHub {
    owner = "intel";
    repo = "torch-xpu-ops";
    rev = "62b793fed8e0a708551d451712af635b6255b322";
    hash = "sha256-CkKtXAUOc4LXbEas2sfIbgSnbxLn+T8rvvSRQm2+gJQ=";
  };
in
(python3Packages.torch.override {
  stdenv = intel-llvm.stdenv;

  tritonSupport = false;

  cudaSupport = false;
  rocmSupport = false;
}).overrideAttrs
  (old: {
    pname = "torch-xpu";

    hardeningDisable = (old.hardeningDisable or [ ]) ++ [
      "zerocallusedregs"
      "pacret"
      "shadowstack"
    ];

    buildInputs = (old.buildInputs or [ ]) ++ [
      level-zero
      mkl
      onednn
      intel-llvm
    ];

    postPatch = (old.postPatch or "") + ''
      # Vendor torch-xpu-ops where cmake expects to have cloned it.
      cp -r ${torch-xpu-ops} third_party/torch-xpu-ops
      chmod -R u+w third_party/torch-xpu-ops

      python3 - <<'PYEOF'
      import re, pathlib

      p = pathlib.Path("caffe2/CMakeLists.txt")
      text = p.read_text()

      start = text.index("set(TORCH_XPU_OPS_REPO_URL")
      end = text.index("set(TORCH_XPU_OPS_INCLUDE_DIRS")
      removed = text[start:end]

      # Guard against a silent no-op if upstream restructures this.
      assert "git clone" in removed, "torch-xpu-ops clone block not found"

      p.write_text(text[:start] + text[end:])
      PYEOF
    '';

    env = (old.env or { }) // {
      USE_XPU = "1";

      # Kineto's XPU profiling path wants Intel PTI, which is not packaged here.
      USE_KINETO = "0";

      # Single GPU: no oneCCL, so no XCCL backend to build.
      USE_XCCL = "0";
      USE_DISTRIBUTED = "0";
    }
    // lib.optionalAttrs (gpuTargets != [ ]) {
      TORCH_XPU_ARCH_LIST = lib.concatStringsSep "," gpuTargets;
    };

    cmakeFlags = (old.cmakeFlags or [ ]) ++ [
      (lib.cmakeBool "USE_XPU" true)
      (lib.cmakeFeature "DNNL_DIR" "${onednn}/lib/cmake/dnnl")
      (lib.cmakeFeature "MKL_ROOT" "${mkl}")
      (lib.cmakeFeature "MKL_DIR" "${mkl}/lib/cmake/mkl")
      (lib.cmakeFeature "LEVEL_ZERO_INCLUDE_DIR" "${level-zero}/include")
    ];

    meta = (old.meta or { }) // {
      description = "PyTorch with the Intel XPU (SYCL) backend";
      platforms = [ "x86_64-linux" ];
    };
  })
