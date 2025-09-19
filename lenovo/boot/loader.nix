{ config, lib, pkgs, ... }:

{
  boot.loader.efi = {
    canTouchEfiVariables = true;
    efiSysMountPoint = "/boot";
  };
  boot.loader.grub = {
    enable = true;
    copyKernels = true;
    device = "nodev";
    efiSupport = true;
    efiInstallAsRemovable = false;
    useOSProber = true;
    memtest86.enable = true;
  };
  boot.loader.timeout = 10;
}