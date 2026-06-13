{ config
, lib
, pkgs
, ... }:

{
  options.hardware.amdgpu = {
    enable = lib.mkEnableOption "Whether to set the GPU as AMD.";
    allowOverclocking = lib.mkEnableOption "Whether to enable AMD Overdrive/Overclocking in the kernel.";
    rocmSupport = lib.mkEnableOption "Whether to setup AMD ROCm.";
  };

  config = lib.mkIf config.hardware.amdgpu.enable {
    hardware = {
      amdgpu.overdrive.enable = config.hardware.amdgpu.allowOverclocking;
      graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = lib.optionals config.hardware.amdgpu.rocmSupport (with pkgs.rocmPackages; [
          # AMD Common Language Runtime for hipamd, opencl, and rocclr
          clr.icd
          clr
          # AMD ROCm Runtime
          rocm-runtime
        ]);
      };
    };

    boot.kernelParams = lib.optionals config.hardware.amdgpu.allowOverclocking [
      "amdgpu.ppfeaturemask=0xfff7ffff"
    ];

    environment.systemPackages = [
      # GPU Control
      pkgs.radeon-profile
    ] ++ lib.optionals config.hardware.amdgpu.rocmSupport (with pkgs.rocmPackages; [
      # nvidia-smi equivalent
      rocm-smi
      # ROCm Information
      rocminfo
      # OpenCL Information (useful for general OpenCL)
      pkgs.clinfo
    ]);

    nixpkgs.config = {
      #
      # yeah, I know it's CUDA, but this is a good option to enable
      # because some prograns are cuda only, and the compatability layer for CUDA on AMD
      # works better than the CPU fallback for most cases.
      #
      # ^ nevermind, what the fuck was I thinking?
      cudaSupport = lib.mkDefault false; # config.hardware.amdgpu.rocmSupport;
      rocmSupport = config.hardware.amdgpu.rocmSupport;
    };

    # This is necesery because a lot of programs hard-code the path to hip
    systemd.tmpfiles.rules = lib.optionals config.hardware.amdgpu.rocmSupport [
      "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
    ];
  };
}