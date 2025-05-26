{ config, lib, pkgs, ... }:

let
  livecd = import (pkgs.path + "/nixos/lib/eval-config.nix") {
    modules = [ ./../rescue-configuration.nix ];
  };
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
      "rescue-initrd" = "${livecd.config.system.build.livecdRamdisk}/initrd";
    };
  };
}