final: prev:

let
  gmmlibRev = "intel-gmmlib-22.10.0";
  levelZeroRev = "v1.32.0";
  igcVersion = "2.38.2";
  computeRuntimeRev = "26.27.39122.11";

  intel-gmmlib-next = prev.intel-gmmlib.overrideAttrs (_old: {
    version = "git";

    src = prev.fetchFromGitHub {
      owner = "intel";
      repo = "gmmlib";
      rev = gmmlibRev;
      hash = "sha256-1JF9zb5aqvUkiPVyDxrmhEC90NwRi/AGQEamEub3gS4=";
    };
  });

  level-zero-next = prev.level-zero.overrideAttrs (_old: {
    version = "git";

    src = prev.fetchFromGitHub {
      owner = "oneapi-src";
      repo = "level-zero";
      rev = levelZeroRev;
      hash = "sha256-u8q8VOuJKUCFNJ8aLR/BrVx9lU5vD+hwkHRmy77vFe8=";
    };
  });

  intel-graphics-compiler-next = prev.intel-graphics-compiler.overrideAttrs (_old: {
    version = igcVersion;

    src = prev.fetchFromGitHub {
      owner = "intel";
      repo = "intel-graphics-compiler";
      rev = "v${igcVersion}";
      hash = "sha256-xLRQzXUSqRVAN0flRlcrsSFZTLFxmQi6ePbm5ks6vhI=";
    };
  });


  intel-compute-runtime-next =
    (prev.intel-compute-runtime.override {
      intel-gmmlib = intel-gmmlib-next;
      intel-graphics-compiler = intel-graphics-compiler-next;
      level-zero = level-zero-next;
    }).overrideAttrs (old: {
      version = "git";

      src = prev.fetchFromGitHub {
        owner = "intel";
        repo = "compute-runtime";
        rev = computeRuntimeRev;
        hash = "sha256-CbOtBgYlvn5r15gB7skmmZ+ZvRwq7FFtouICakku0ls=";
      };

      postPatch = (old.postPatch or "") + ''
        substituteInPlace \
          level_zero/sysman/source/shared/linux/tracefs_api/CMakeLists.txt \
          --replace-fail \
            '  if(LIBTRACEFS_FOUND)' \
            '  if(TRUE)'

        substituteInPlace shared/source/os_interface/product_helper.cpp \
          --replace-fail \
            '    hwInfo.capabilityTable.requiredPreemptionSurfaceSize = hwInfo.gtSystemInfo.CsrSizeInMb * MemoryConstants::megaByte;' \
            '    if (hwInfo.gtSystemInfo.CsrSizeInMb == 0) {
              hwInfo.gtSystemInfo.CsrSizeInMb = 8;
          }

          hwInfo.capabilityTable.requiredPreemptionSurfaceSize =
              hwInfo.gtSystemInfo.CsrSizeInMb * MemoryConstants::megaByte;'
      '';
    });
in
{
  intel-gmmlib = intel-gmmlib-next;
  level-zero = level-zero-next;
  intel-graphics-compiler = intel-graphics-compiler-next;
  intel-compute-runtime = intel-compute-runtime-next;
}