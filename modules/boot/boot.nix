{ config
, lib
, ... }:

{
  options.hardware = {
    amd = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to set the CPU as AMD.";
      };
      enableIommu = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to enable iommu in the kernel.";
      };
    };
    intel = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to set the CPU as Intel.";
      };
    };
    enableKvm = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable KVM.";
    };
  };

  config = {
    boot = {
      consoleLogLevel = lib.mkDefault 0;
      initrd = {
        kernelModules = [ ];
        systemd.enable = true;
      };
      kernelModules = [ ] ++ lib.optionals config.hardware.enableKvm [
        (lib.strings.optionalString config.hardware.amd.enable "kvm-amd")
        (lib.strings.optionalString config.hardware.intel.enable "kvm-intel")
      ];
      kernelParams = [
        # Enable high-poll rate USB Keyboard devices
        "usbhid.kbpoll=1"
        # Boot a shell on failure
        "boot.shell_on_fail"
        # Show systemd
        "rd.systemd.show_status=auto"
      ] ++ lib.optionals config.hardware.amd.enableIommu [
        "amd_iommu=on"
      ];
      tmp.useTmpfs = false;
    };

    hardware.cpu.amd.updateMicrocode = config.hardware.amd.enable;
    hardware.cpu.intel.updateMicrocode = config.hardware.intel.enable;
  };
}