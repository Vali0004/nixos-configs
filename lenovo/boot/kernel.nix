{ config, lib, pkgs, ... }:

{
  boot.kernelModules = [
    "kvm-amd"
  ];
  boot.kernelParams = [
    # Enable IOMMU
    "amd_iommu=on"
    # Allow GPU overclocking from sysfs
    "amdgpu.ppfeaturemask=0xfff7ffff"
    # Enable high-poll rate
    "usbhid.kbpoll=1"
    "boot.shell_on_fail"
    "splash"
    "rd.systemd.show_status=auto"
  ];
}
