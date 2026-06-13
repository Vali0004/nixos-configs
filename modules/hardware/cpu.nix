{ config
, lib
, pkgs
, ... }:

{
  options.hardware = {
    amd = {
      enable = lib.mkEnableOption "Whether to set the CPU as AMD.";
      enableIommu = lib.mkEnableOption "Whether to enable IOMMU (Input Output Memory Management Unit) in the kernel.";
    };
    intel = {
      enable = lib.mkEnableOption "Whether to set the CPU as Intel.";
    };
    opencl = {
      enable = lib.mkEnableOption "Sets up OpenCL spport on the CPU side.";
    };
    enableKvm = lib.mkEnableOption "Whether to enable KVM support in the kernel.";
  };

  config = {
    hardware = {
      cpu = {
        amd.updateMicrocode = config.hardware.amd.enable;
        intel.updateMicrocode = config.hardware.intel.enable;
      };
      graphics.extraPackages = lib.optionals config.hardware.opencl.enable (with pkgs; [
        intel-compute-runtime
        intel-ocl
      ]);
    };

    environment.systemPackages = lib.optionals config.hardware.opencl.enable (with pkgs; [
      # OpenCL ICD Loader
      ocl-icd
      # OpenCL Information
      clinfo
    ]);
  };
}