{ config, lib, pkgs, ... }:

let
  livecd = import (pkgs.path + "/nixos/lib/eval-config.nix") {
    modules = [
      (pkgs.path + "/nixos/modules/installer/netboot/netboot-minimal.nix")
      rescue/configuration.nix
    ];
  };
in {
  options.boot.grub = {
    device = lib.mkOption {
      type = lib.types.str;
      default = "/dev/sda";
      description = "Which device to install GRUB to.";
    };
    efi = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to GRUB2's EFI support.";
      };
      removable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to install as removable or not (rarely needed).";
      };
    };
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to GRUB2.";
    };
    enableMemtest = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to add a memtest86 entry.";
    };
    enableRescue = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to add a small rescue environment to the bootloader.";
    };
    copyKernels = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to copy kernels to /boot";
    };
    configurationLimit = lib.mkOption {
      type = lib.types.int;
      default = 100;
      description = "Number of configurations to keep";
    };
  };

  config.boot.loader = lib.mkIf config.boot.grub.enable {
    efi = lib.mkIf config.boot.grub.efi.enable {
      canTouchEfiVariables = !config.boot.grub.efi.removable;
      efiSysMountPoint = "/boot";
    };
    grub = {
      enable = true;
      configurationLimit = config.boot.grub.configurationLimit;
      copyKernels = config.boot.grub.copyKernels;
      device = if config.boot.grub.efi.enable then "nodev" else config.boot.grub.device;
      efiSupport = config.boot.grub.efi.enable;
      efiInstallAsRemovable = config.boot.grub.efi.removable;
      extraEntries = lib.optionalString config.boot.grub.enableRescue ''
        menuentry "NixOS Recuse" {
          linux ($drive1)/rescue-kernel init=${livecd.config.system.build.toplevel}/init ${toString livecd.config.boot.kernelParams}
          initrd ($drive1)/rescue-initrd
        }
      '';
      extraFiles = lib.mkIf config.boot.grub.enableRescue {
        "rescue-kernel" = "${livecd.config.system.build.kernel}/bzImage";
        "rescue-initrd" = "${livecd.config.system.build.netbootRamdisk}/initrd";
      };
      useOSProber = true;
      memtest86.enable = config.boot.grub.enableMemtest;
    };
    timeout = 10;
  };
}