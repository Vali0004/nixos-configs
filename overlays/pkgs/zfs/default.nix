{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch2,
  autoreconfHook269,
  util-linux,
  nukeReferences,
  coreutils,
  linuxPackages,
  perl,
  udevCheckHook,
  configFile ? "all",

  # Userspace dependencies
  zlib,
  libuuid,
  python3,
  attr,
  openssl,
  libtirpc,
  nfs-utils,
  gawk,
  gnugrep,
  gnused,
  systemd,
  smartmontools,
  enableMail ? false,
  sysstat,
  pkg-config,
  curl,
  pam,
  nix-update-script,

  # Kernel dependencies
  kernel ? null,
  kernelModuleMakeFlags ? [ ],
  enablePython ? true,
  ...
}@outerArgs:

# Wrap in a named function so passthru.userspaceTools can call back into it
# without needing an external `genericBuild` reference.
let
  buildZfs =
    outerArgs':
    {
      version ? "2.4.2",
      hash ? "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=",
      kernelModuleAttribute ? "zfs_unstable",
      extraLongDescription ? "",
      extraPatches ? [ ],
      rev ? "af50420ac624caeae2cf157378ea6b5dcd394c46",
      kernelMinSupportedMajorMinor ? "4.18",
      kernelMaxSupportedMajorMinor ? "7.0",
      enableUnsupportedExperimentalKernel ? false,
      maintainers ? (with lib.maintainers; [ amarshall ]),
      tests,
    }@innerArgs:

    let
      inherit (lib)
        elem
        optionalString
        optionals
        optional
        makeBinPath
        ;

      # Pull the resolved configFile out of the (possibly-overridden) outerArgs'.
      configFile' = outerArgs'.configFile or configFile;

      smartmon = smartmontools.override { inherit enableMail; };

      buildKernel = elem configFile' [
        "kernel"
        "all"
      ];
      buildUser = elem configFile' [
        "user"
        "all"
      ];

      # Resolve kernel from outerArgs' (may differ when building userspaceTools).
      kernel' = outerArgs'.kernel or kernel;

      kernelIsCompatible =
        k:
        (lib.versionAtLeast k.version kernelMinSupportedMajorMinor)
        && (lib.versionAtLeast kernelMaxSupportedMajorMinor (lib.versions.majorMinor k.version));

      stdenv' = if kernel' == null then stdenv else kernel'.stdenv;
    in

    assert (configFile' == "kernel") -> (kernel' != null);

    stdenv'.mkDerivation {
      name = "zfs-${configFile'}-${version}${optionalString buildKernel "-${kernel'.version}"}";
      pname = "zfs";
      inherit version;

      src = fetchFromGitHub {
        owner = "cleverca22";
        repo = "zfs";
        inherit rev hash;
      };

      patches =
        extraPatches
        ++ lib.optional (kernel' != null && lib.versionOlder kernel'.version "5.14") (fetchpatch2 {
          url = "https://github.com/openzfs/zfs/commit/58c8dc5f6926eb96903a3f38b141e8998ef9261b.patch?full_index=1";
          hash = "sha256-eYkMhHsHBA9MKXnB/GuHpuv44g1SCGV5Or0InPBeNkU=";
        });

      postPatch =
        optionalString buildKernel ''
          patchShebangs scripts
          # The arrays must remain the same length, so we repeat a flag that is
          # already part of the command and therefore has no effect.
          substituteInPlace ./module/os/linux/zfs/zfs_ctldir.c \
            --replace-fail '"/usr/bin/env", "umount"' '"${util-linux}/bin/umount", "-n"' \
            --replace-fail '"/usr/bin/env", "mount"'  '"${util-linux}/bin/mount", "-n"'
        ''
        + optionalString buildUser ''
          #substituteInPlace ./lib/libshare/os/linux/nfs.c --replace-fail "/usr/sbin/exportfs" "${
            nfs-utils.override (old: {
              enablePython = old.enablePython or true && enablePython;
            })
          }/bin/exportfs"
          #substituteInPlace ./lib/libshare/smb.h        --replace-fail "/usr/bin/net"            "/run/current-system/sw/bin/net"
          # Disable dynamic loading of libcurl
          substituteInPlace ./config/user-libfetch.m4   --replace-fail "curl-config --built-shared" "true"
          substituteInPlace ./config/user-systemd.m4    --replace-fail "/usr/lib/modules-load.d" "$out/etc/modules-load.d"
          substituteInPlace ./config/zfs-build.m4       --replace-fail "\$sysconfdir/init.d"     "$out/etc/init.d" \
                                                        --replace-fail "/etc/default"            "$out/etc/default"
          substituteInPlace ./contrib/initramfs/Makefile.am \
            --replace-fail "/usr/share/initramfs-tools" "$out/usr/share/initramfs-tools"

          substituteInPlace ./udev/vdev_id \
            --replace-fail "PATH=/bin:/sbin:/usr/bin:/usr/sbin" \
             "PATH=${
               makeBinPath [
                 coreutils
                 gawk
                 gnused
                 gnugrep
                 systemd
               ]
             }"

          substituteInPlace ./lib/libzfs/libzfs_util.c \
            --replace-fail \"PATH=/bin:/sbin:/usr/bin:/usr/sbin\" \
            \"PATH=/run/wrappers/bin:/run/current-system/sw/bin:/run/current-system/sw/sbin\"

          substituteInPlace ./config/zfs-build.m4 \
            --replace-fail "bashcompletiondir=/etc/bash_completion.d" \
              "bashcompletiondir=$out/share/bash-completion/completions"
        ''
        + lib.optionalString (lib.versionOlder version "2.4.0") ''
          substituteInPlace ./cmd/arc_summary --replace-fail "/sbin/modinfo" "modinfo"
        ''
        + lib.optionalString (lib.versionAtLeast version "2.4.0") ''
          substituteInPlace ./cmd/zarcsummary --replace-fail "/sbin/modinfo" "modinfo"
        ''
        + ''
          sed -i 's/^Linux-Maximum: .*/Linux-Maximum: ${kernelMaxSupportedMajorMinor}/' META
          sed -i 's/^Linux-Minimum: .*/Linux-Minimum: ${kernelMinSupportedMajorMinor}/' META
          echo 'Supported Kernel versions:'
          grep '^Linux-' META
          echo 'Checking kernelMinSupportedMajorMinor is correct...'
          grep --quiet '^Linux-Minimum: *${lib.escapeRegex kernelMinSupportedMajorMinor}$' META
          echo 'Checking kernelMaxSupportedMajorMinor is correct...'
          grep --quiet '^Linux-Maximum: *${lib.escapeRegex kernelMaxSupportedMajorMinor}$' META
        '';

      nativeBuildInputs = [
        autoreconfHook269
        nukeReferences
      ]
      ++ optionals buildKernel (kernel'.moduleBuildDependencies ++ [ perl ])
      ++ optionals buildUser [
        pkg-config
        udevCheckHook
      ];
      buildInputs =
        optionals buildUser [
          zlib
          libuuid
          attr
          libtirpc
          pam
        ]
        ++ optional buildUser openssl
        ++ optional buildUser curl
        ++ optional (buildUser && enablePython) python3;

      env.NIX_CFLAGS_LINK = "-lgcc_s";

      hardeningDisable = [
        "fortify"
        "stackprotector"
        "pic"
      ];

      configureFlags = [
        "--with-config=${configFile'}"
        "--with-tirpc=1"
        (lib.withFeatureAs (buildUser && enablePython) "python" python3.interpreter)
      ]
      ++ optional enableUnsupportedExperimentalKernel "--enable-linux-experimental"
      ++ optionals buildUser [
        "--with-dracutdir=$(out)/lib/dracut"
        "--with-udevdir=$(out)/lib/udev"
        "--with-systemdunitdir=$(out)/etc/systemd/system"
        "--with-systemdpresetdir=$(out)/etc/systemd/system-preset"
        "--with-systemdgeneratordir=$(out)/lib/systemd/system-generator"
        "--with-mounthelperdir=$(out)/bin"
        "--libexecdir=$(out)/libexec"
        "--sysconfdir=/etc"
        "--localstatedir=/var"
        "--enable-systemd"
        "--enable-pam"
      ]
      ++ optionals buildKernel (
        [
          "--with-linux=${kernel'.dev}/lib/modules/${kernel'.modDirVersion}/source"
          "--with-linux-obj=${kernel'.dev}/lib/modules/${kernel'.modDirVersion}/build"
        ]
        ++ map (f: "KERNEL_${f}") kernelModuleMakeFlags
      );

      enableParallelBuilding = true;

      doInstallCheck = true;

      installFlags = [
        "sysconfdir=\${out}/etc"
        "DEFAULT_INITCONF_DIR=\${out}/default"
        "INSTALL_MOD_PATH=\${out}"
      ];

      preConfigure = ''
        export TEST_JOBS=$NIX_BUILD_CORES
        if [ -z "$enableParallelBuilding" ]; then
          export TEST_JOBS=1
        fi
      '';

      postBuild = optionalString buildKernel ''
        find . -name "*.ko" -print0 | xargs -0 -P$NIX_BUILD_CORES ${stdenv.cc.targetPrefix}strip --strip-debug
      '';

      postInstall =
        optionalString buildKernel ''
          mkdir -p "$out/nix-support"
          echo "${util-linux}" >> "$out/nix-support/extra-refs"
        ''
        + optionalString buildUser ''
          rm $out/etc/systemd/system/zfs-import-*.service

          for i in $out/etc/systemd/system/*; do
             if [ -L $i ]; then
               continue
             fi
             sed -i '/zfs-import-scan.service/d' $i
             substituteInPlace $i --replace-warn "zfs-import-cache.service" "zfs-import.target"
          done

          rm -rf $out/share/zfs/zfs-tests
        '';

      postFixup =
        let
          path = "PATH=${
            makeBinPath [
              coreutils
              gawk
              gnused
              gnugrep
              util-linux
              smartmon
              sysstat
            ]
          }:$PATH";
        in
        ''
          for i in $out/libexec/zfs/zpool.d/*; do
            sed -i '2i${path}' $i
          done
        '';

      outputs = [
        "out"
      ]
      ++ optionals buildUser [
        "dev"
      ]
      ++ optionals (!buildKernel) [
        "man"
      ];

      passthru = {
        kernel = kernel';
        inherit enableMail kernelModuleAttribute;
        latestCompatibleLinuxPackages = lib.warn "zfs.latestCompatibleLinuxPackages is deprecated and is now pointing at the default kernel. If using the stable LTS kernel (default `linuxPackages` is not possible then you must explicitly pin a specific kernel release. For example, `boot.kernelPackages = pkgs.linuxPackages_6_6`. Please be aware that non-LTS kernels are likely to go EOL before ZFS supports the latest supported non-LTS release, requiring manual intervention." linuxPackages;

        userspaceTools = buildZfs (outerArgs' // { configFile = "user"; }) innerArgs;

        inherit tests;
      }
      // lib.optionalAttrs (kernelModuleAttribute != "zfs_unstable") {
        updateScript = nix-update-script {
          extraArgs = [
            "--version-regex=^zfs-(${lib.versions.major version}\\.${lib.versions.minor version}\\.[0-9]+)"
            "--override-filename=pkgs/os-specific/linux/zfs/${lib.versions.major version}_${lib.versions.minor version}.nix"
          ];
        };
      };

      meta = {
        description = "ZFS Filesystem Linux" + (if buildUser then " Userspace Tools" else " Kernel Module");
        longDescription = ''
          ZFS is a filesystem that combines a logical volume manager with a
          Copy-On-Write filesystem with data integrity detection and repair,
          snapshotting, cloning, block devices, deduplication, and more.

          ${
            if buildUser then "This is the userspace tools package." else "This is the kernel module package."
          }
        ''
        + extraLongDescription;
        homepage = "https://github.com/openzfs/zfs";
        changelog = "https://github.com/openzfs/zfs/releases/tag/zfs-${version}";
        license = lib.licenses.cddl;

        platforms =
          with lib.systems.inspect.patterns;
          map (p: p // isLinux) [
            isx86
            isAarch
            isPower
            isS390
            isSparc
            isMips
            isRiscV64
            isLoongArch64
          ];

        inherit maintainers;
        mainProgram = "zfs";
        broken = buildKernel && !((kernelIsCompatible kernel') || enableUnsupportedExperimentalKernel);
      };
    };
in

buildZfs outerArgs
