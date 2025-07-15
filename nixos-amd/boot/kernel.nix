{ config, lib, pkgs, ... }:

{
  boot.kernelModules = [
    "kvm-amd"
  ];
  boot.kernelParams = [
    # Enable IOMMU
    "amd_iommu=on"
    # Enable high-poll rate
    "usbhid.kbpoll=1"
    "boot.shell_on_fail"
    "splash"
    "rd.systemd.show_status=auto"
  ];
  boot.kernelPackages = let
    version = "6.14.2";
    suffix = "zen1";
  in pkgs.linuxPackagesFor (pkgs.linux_zen.override {
    inherit version suffix;
    modDirVersion = lib.versions.pad 3 "${version}-${suffix}";
    src = pkgs.fetchFromGitHub {
      owner = "zen-kernel";
      repo = "zen-kernel";
      rev = "v${version}-${suffix}";
    };
  });
  boot.kernelPatches = [{
    # ALVR has a stroke, as it needs this for asynchronous reprojection
    # However, NixOS runs steam in a bubble-wrapped env simply due to how NixOS works. It emulates a Debian install to make Steam happy
    # This just makes amdgpu say "Fuck it, we'll do it anyways"
    name = "amdgpu-ignore-ctx-privileges";
    patch = pkgs.fetchpatch {
      name = "cap_sys_nice_begone.patch";
      url = "https://github.com/Frogging-Family/community-patches/raw/master/linux61-tkg/cap_sys_nice_begone.mypatch";
      hash = "sha256-Y3a0+x2xvHsfLax/uwycdJf3xLxvVfkfDVqjkxNaYEo=";
    };
  }];
}
