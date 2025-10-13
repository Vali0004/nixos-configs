{ config, lib, pkgs, ... }:

{
  # I don't own a intel machine, so I won't set it up for now
  options.hardware.amdgpu = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to set the CPU as AMD.";
    };
    allowOverclocking = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable iommu in the kernel.";
    };
  };

  config = lib.mkIf config.hardware.amdgpu.enable {
    hardware = {
      amdgpu.overdrive.enable = config.hardware.amdgpu.allowOverclocking;
      graphics = {
        enable = true;
        enable32Bit = true;
      };
    };

    boot.kernelParams = lib.optionals config.hardware.amdgpu.allowOverclocking [
      "amdgpu.ppfeaturemask=0xfff7ffff"
    ];

    environment.systemPackages = [
      # GPU Control
      pkgs.radeon-profile
    ];
  };
}
