{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  level-zero,
  igsc,
  metee,
  systemdLibs,
  libpciaccess,
  openssl,
  zlib,
  libcap,
  lua5_2,
  hwloc,
  makeWrapper,
}:

# Intel XPU Manager's `xpu-smi` CLI - the Intel counterpart to nvidia-smi.
#
# Pinned to the 1.3.x line: 2.1.0 builds but misreports Battlemage as
# "Device State: survivability mode" on a healthy GPU, while 1.3.x reports
# correctly. 1.3.x also still uses CMake; 2.x moved to Meson + Conan.
#
# DAEMONLESS=ON builds only the standalone CLI, dropping the xpumd daemon and
# its gRPC/protobuf dependency stack.
stdenv.mkDerivation (finalAttrs: {
  pname = "xpu-smi";
  version = "1.3.7";

  src = fetchFromGitHub {
    owner = "intel";
    repo = "xpumanager";
    tag = "v${finalAttrs.version}";
    hash = "sha256-uFFyWnYXQQlsT+oE5w6FxJkeLSQpF/qE2izg4rnrDTw=";
  };

  nativeBuildInputs = [ cmake pkg-config makeWrapper ];

  buildInputs = [
    level-zero
    igsc
    metee
    hwloc
    systemdLibs
    libpciaccess
    openssl
    zlib
    libcap
    lua5_2
  ];

  postPatch = ''
    patchShebangs third_party/hwloc

    # Upstream vendors hwloc and builds it from CMake via an autotools script.
    # That build does not survive the sandbox: it configures with
    # LDFLAGS="--static" (no static libc here) and its install step does not
    # leave libhwloc.a where CMake later looks. Use the nixpkgs hwloc instead
    # and make the vendored build a no-op.
    cat > third_party/hwloc/build.sh <<'EOF'
#!/bin/sh
# neutered: hwloc is provided via buildInputs
exit 0
EOF
    chmod +x third_party/hwloc/build.sh
  '';

  # core/CMakeLists.txt looks for the Level Zero headers under /usr/include and
  # /usr/local/include, and expects hwloc's headers in the vendored tree.
  # Append here rather than setting NIX_CFLAGS_COMPILE as a derivation
  # attribute, which would replace the value stdenv derives from buildInputs.
  preConfigure = ''
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -I${lib.getDev hwloc}/include"
  '';

  cmakeFlags = [
    (lib.cmakeBool "DAEMONLESS" true)
    (lib.cmakeBool "BUILD_DOC" false)
    # Upstream declares cmake_minimum_required below 3.5, which current CMake
    # refuses outright.
    (lib.cmakeFeature "CMAKE_POLICY_VERSION_MINIMUM" "3.5")
    # Skips a distro-detection block that dereferences an unset ${os_name} and
    # errors on anything that is not Debian/RHEL/SUSE. Only affects CPack.
    (lib.cmakeFeature "CPACK_GENERATOR" "TGZ")
    # Link with the final RPATH instead of letting CMake rewrite it at install
    # time; the rewrite fails because nixpkgs' linker wrapper has already set a
    # RUNPATH that does not match what CMake expects to find.
    (lib.cmakeBool "CMAKE_BUILD_WITH_INSTALL_RPATH" true)
    (lib.cmakeFeature "CMAKE_INSTALL_RPATH" "${placeholder "out"}/lib")
  ];

  # Level Zero only exposes the sysman API (power, frequency, memory, engine
  # counters) when ZES_ENABLE_SYSMAN=1; without it every metric reads N/A.
  # Note that utilisation and temperature additionally require root.
  postInstall = ''
    wrapProgram $out/bin/xpu-smi --set-default ZES_ENABLE_SYSMAN 1
  '';

  meta = {
    description = "Intel XPU Manager CLI (xpu-smi) for monitoring Intel datacenter and Arc GPUs";
    homepage = "https://github.com/intel/xpumanager";
    license = lib.licenses.mit;
    mainProgram = "xpu-smi";
    platforms = [ "x86_64-linux" ];
  };
})
