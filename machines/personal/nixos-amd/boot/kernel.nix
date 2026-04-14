{ lib
, modulesPath
, pkgs
, ... }:

{
  boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.linux_latest.override {
    argsOverride = rec {
      src = pkgs.fetchurl {
        url = "mirror://kernel/linux/kernel/v7.x/linux-${version}.tar.xz";
        #url = "https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/snapshot/linux-7.0.tar.gz";
        hash = "sha256-u39tgLOHx1e30Uu5MCj8uQ95PFwNNnc27oFaEAs4kfA=";
      };
      version = "7.0";
      modDirVersion = "7.0.0";
    };
  });

  boot.kernelPatches = [
    {
      # VR has a stroke, as it needs this for asynchronous reprojection
      # However, NixOS runs steam in a bubble-wrapped env simply due to how NixOS works. It emulates a Debian install to make Steam happy
      # This just makes amdgpu say "Fuck it, we'll do it anyways"
      name = "amdgpu-ignore-ctx-privileges";
      patch = pkgs.fetchpatch {
        name = "cap_sys_nice_begone.patch";
        url = "https://github.com/Frogging-Family/community-patches/raw/master/linux61-tkg/cap_sys_nice_begone.mypatch";
        hash = "sha256-Y3a0+x2xvHsfLax/uwycdJf3xLxvVfkfDVqjkxNaYEo=";
      };
    }
    # https://pixelcluster.github.io/VRAM-Mgmt-fixed/
    {
      name = "vram-mgmt-fix-0001";
      patch = pkgs.fetchpatch {
        name = "vram-mgmt-fix-0001.patch";
        url = "https://gitlab.freedesktop.org/pixelcluster/kernel/-/commit/9d928b2c5af078304205c12c71fec4904860d8cc.patch";
        hash = "sha256-nKgCtyAlJAm9ivkkvnR9fyI/vimKfqtHc2hEwOKomJg=";
      };
    }
    {
      name = "vram-mgmt-fix-0002";
      patch = pkgs.fetchpatch {
        name = "vram-mgmt-fix-0002.patch";
        url = "https://gitlab.freedesktop.org/pixelcluster/kernel/-/commit/9a02490c9f7938a4ed8950f0d61bcf677f67c07b.patch";
        hash = "sha256-LLVlO09pGaoQWnHlN9LbqAWWHwk8EWZAAohxmr6KrKE=";
      };
    }
    {
      name = "vram-mgmt-fix-0003";
      patch = pkgs.fetchpatch {
        name = "vram-mgmt-fix-0003.patch";
        url = "https://gitlab.freedesktop.org/pixelcluster/kernel/-/commit/1f24ddd4ffd04f47a04bd84987f36dc545bc7421.patch";
        hash = "sha256-m4qggskuEvTDh30NaahEVAX5zYmyZDWK7QbKfyxbCeY=";
      };
    }
    {
      name = "vram-mgmt-fix-0004";
      patch = pkgs.fetchpatch {
        name = "vram-mgmt-fix-0004.patch";
        url = "https://gitlab.freedesktop.org/pixelcluster/kernel/-/commit/f6bde8345b0c66e9cd81fa368343d4438ac9b3b0.patch";
        hash = "sha256-iK2koTWdYVLscZhTughpF2h+RMH7wrzVZb7VgXxvNeA=";
      };
    }
    {
      name = "vram-mgmt-fix-0005";
      patch = pkgs.fetchpatch {
        name = "vram-mgmt-fix-0005.patch";
        url = "https://gitlab.freedesktop.org/pixelcluster/kernel/-/commit/68f051af747220ac7d1d74bec8d79f2cb3a58304.patch";
        hash = "sha256-wZRa2DzTv/evIkjODVPTXWCvQEKVVfVmRL4TgkIC/+w=";
      };
    }
    {
      name = "vram-mgmt-fix-0006";
      patch = pkgs.fetchpatch {
        name = "vram-mgmt-fix-0006.patch";
        url = "https://gitlab.freedesktop.org/pixelcluster/kernel/-/commit/9260440455cd61f2c90cca172bc9d3e83bf1206d.patch";
        hash = "sha256-1gKaAsO42oYjOKSwNCtKjEMCo5tz+Fo3+Qg0Kj8+bHo=";
      };
    }
  ];
}