{ config, lib, pkgs, ... }:

let
  livecd = import (pkgs.path + "/nixos/lib/eval-config.nix") {
    modules = [
      (pkgs.path + "/nixos/modules/installer/netboot/netboot-minimal.nix")
      module
    ];
  };
  module = import ./configuration.nix;
in {
  boot.loader.efi = {
    canTouchEfiVariables = true;
    efiSysMountPoint = "/boot";
  };

  boot.loader.grub = {
    extraEntries = ''
      menuentry "NixOS Recuse" {
        linux ($drive1)/rescue-kernel init=${livecd.config.system.build.toplevel}/init ${toString livecd.config.boot.kernelParams}
        initrd ($drive1)/rescue-initrd
      }
    '';
    extraFiles = {
      "rescue-kernel" = "${livecd.config.system.build.kernel}/bzImage";
      "rescue-initrd" = "${livecd.config.system.build.netbootRamdisk}/initrd";
    };
  };
}