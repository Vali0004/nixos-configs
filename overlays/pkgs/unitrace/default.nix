{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  python3,
  git,
  level-zero,
  ocl-icd,
  opencl-headers,
  intel-llvm,
  makeWrapper,
  metrics-discovery,
  metrics-library,
}:

# unitrace, from Intel's pti-gpu - traces and profiles Level Zero / SYCL
# workloads on Intel GPUs. Gives per-kernel timing plus, via the metrics
# libraries, EU-level hardware counters (active/stall, memory traffic), which
# is what distinguishes it from a plain kernel timer.
#
# Built from the unitrace-* tag rather than a pti-* one: pti-gpu tags the
# library and the tool independently, and the tool's tags track unitrace.
#
# Note that the README's BUILD_WITH_* option table does not match this tag:
# both the ittapi download and find_package(Xptifw REQUIRED) sit outside their
# respective guards, so ITT and XPTI are hard requirements regardless of the
# flags. Both are satisfied below rather than disabled.
stdenv.mkDerivation (finalAttrs: {
  pname = "unitrace";
  version = "2.0.2";

  src = fetchFromGitHub {
    owner = "intel";
    repo = "pti-gpu";
    tag = "unitrace-${finalAttrs.version}";
    hash = "sha256-L+O9oBWMTIPvBSmHUs0brToTDUwGrrzckHZBSX5gjR8=";
  };

  # scripts/get_itt.py git-clones this at configure time, which cannot work in
  # the sandbox. The commit is the ITT_HASH pinned in tools/unitrace/CMakeLists.txt
  # and must be updated alongside it.
  ittapi = fetchFromGitHub {
    owner = "intel";
    repo = "ittapi";
    rev = "47467459a7984988ab838b5108c03ab1cf0a3f73";
    hash = "sha256-3AMYid0IhMxtJq/D0qMPGXiDt5Llj45/3mrDEn9OqLE=";
  };

  # build_utils/get_cl_tracing_headers.py clones this for exactly three headers
  # (tracing_api.h, tracing_types.h, cl_ext_private.h). Commit is pinned at the
  # top of that script. OpenCL support is not optional in this tag despite
  # BUILD_WITH_OPENCL existing in the docs, so it cannot simply be turned off.
  compute-runtime = fetchFromGitHub {
    owner = "intel";
    repo = "compute-runtime";
    rev = "ca7d47598a63959d42750c62a2981e08ffa392a1";
    hash = "sha256-vXDi5DO34YfH7oiraxtut1O+CPs1jMC09QXsWObnq/8=";
  };

  # Likewise for build_utils/get_cl_headers.py.
  opencl-headers-src = fetchFromGitHub {
    owner = "KhronosGroup";
    repo = "OpenCL-Headers";
    rev = "dcd5bede6859d26833cd85f0d6bbcee7382dc9b3";
    hash = "sha256-94rZeGuVvzQVBvwxpJWiiDs+RxTQqWKs0jeYzqBiQew=";
  };

  sourceRoot = "${finalAttrs.src.name}/tools/unitrace";

  # git is only needed so scripts/get_commit_hash.py can exec it; outside a
  # repo it returns empty and the generated COMMIT_HASH is blank, which is
  # fine. Without the binary present the script dies with FileNotFoundError.
  nativeBuildInputs = [ cmake pkg-config python3 git makeWrapper ];

  buildInputs = [ level-zero ocl-icd opencl-headers intel-llvm ];

  # Upstream mixes the two target_link_libraries signatures on unitrace_tool:
  # this line uses the keyword form while build_utils/CMakeLists.txt links the
  # OpenCL loader onto the same target with the plain form, which CMake
  # rejects outright. build_utils has ~14 plain uses and this is the only
  # keyword one, so drop the keyword here rather than convert all of those.
  postPatch = ''
    # zetMetricGroupCalculateMultipleMetricValuesExp fails with
    # ZE_RESULT_ERROR_INVALID_SIZE unless the raw buffer it is given is an
    # exact whole number of OA reports. Upstream reads the capture back in
    # fixed MAX_METRIC_BUFFER-sized chunks, which split a report whenever the
    # capture exceeds one chunk, so every chunk but the last decodes to nothing
    # and the metric table comes out empty. The file is always a whole number
    # of reports (a concatenation of zetMetricStreamerReadData results), so
    # read it in one piece.
    #
    # Only the read call is rewritten, and it resizes the buffer itself. The
    # identical raw_metrics declaration in the collector thread is deliberately
    # left alone: ReadMetrics() writes into storage.data() without resizing, so
    # shrinking that one would overflow.
    python3 - <<'EOF'
p = "src/levelzero/ze_metrics.h"
s = open(p).read()
old = "inf.read(reinterpret_cast<char *>(raw_metrics.data()), MAX_METRIC_BUFFER + 512);"
new = ("inf.seekg(0, std::ios::end); raw_metrics.resize((size_t) inf.tellg());"
       " inf.seekg(0, std::ios::beg);"
       " inf.read(reinterpret_cast<char *>(raw_metrics.data()), raw_metrics.size());"
       # reading exactly size bytes does not set eofbit, and the caller loops
       # on !inf.eof(), so without this the same data is decoded forever.
       " inf.peek();")
n = s.count(old)
assert n == 2, "expected 2 reader read calls, found %d" % n
open(p, "w").write(s.replace(old, new))
EOF

    # TEMP diagnostics: the metric decode failure paths swallow the status code.
    sed -i 's|std::cerr << "\[WARNING\] Unable to calculate metrics" << std::endl;|std::cerr << "[WARNING] Unable to calculate metrics: status=0x" << std::hex << (int)status << std::dec << " raw_size=" << raw_size << " num_samples=" << num_samples << " num_metrics=" << num_metrics << std::endl;|g' src/levelzero/ze_metrics.h

    substituteInPlace CMakeLists.txt \
      --replace-fail 'target_link_libraries(unitrace_tool PRIVATE Xptifw::Xptifw)' \
                     'target_link_libraries(unitrace_tool Xptifw::Xptifw)'
  '';

  # get_itt.py only clones when its target directory is absent, so pre-placing
  # the checkout makes it skip the network and go straight to copying headers
  # into ittheaders/. cwd here is the source root; cmake cds into build/ later.
  preConfigure = ''
    mkdir -p build
    cp -r ${finalAttrs.ittapi} build/ittapi
    cp -r ${finalAttrs.compute-runtime} build/compute-runtime
    cp -r ${finalAttrs.opencl-headers-src} build/OpenCL-Headers
    chmod -R u+w build/ittapi build/compute-runtime build/OpenCL-Headers
  '';

  cmakeFlags = [
    (lib.cmakeFeature "CMAKE_BUILD_TYPE" "Release")
    (lib.cmakeFeature "BUILD_WITH_MPI" "0")
    (lib.cmakeFeature "BUILD_WITH_OMP" "0")
    # cmake/FindXptifw.cmake only searches LD_LIBRARY_PATH/LIBRARY_PATH, which
    # the sandbox does not populate, so point it at the DPC++ tree directly.
    (lib.cmakeFeature "Xptifw_LIBRARY" "${intel-llvm}/lib/libxptifw.so")
    (lib.cmakeFeature "Xptifw_INCLUDE_DIR" "${intel-llvm}/include")
    # Used verbatim in target_include_directories/link_directories.
    (lib.cmakeFeature "ONEAPI_COMPILER_HOME" "${intel-llvm}")
    (lib.cmakeFeature "CMAKE_POLICY_VERSION_MINIMUM" "3.5")
  ];

  # unitrace injects its collector via LD_PRELOAD into the traced process, so
  # the metrics libraries must resolve from that process, not just from
  # unitrace itself. Hence LD_LIBRARY_PATH rather than an RPATH.
  postInstall = ''
    wrapProgram $out/bin/unitrace \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ metrics-discovery metrics-library level-zero intel-llvm ]}"
  '';

  meta = {
    description = "Intel GPU performance tracing and profiling tool (pti-gpu)";
    homepage = "https://github.com/intel/pti-gpu";
    license = lib.licenses.mit;
    mainProgram = "unitrace";
    platforms = [ "x86_64-linux" ];
  };
})
