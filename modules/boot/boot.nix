{ config, lib, ... }:

{
  # I don't own a intel machine, so I won't set it up for now
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
    enableKvm = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable KVM.";
    };
  };

  config = {
    boot = {
      consoleLogLevel = 8;
      initrd = {
        kernelModules = [ ];
        systemd.enable = true;
      };
      kernelModules = [ ] ++ lib.optionals config.hardware.enableKvm [
        (lib.strings.optionalString config.hardware.amd.enable "kvm-amd")
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
      kernel.sysctl = {
        "net.ipv4.tcp_low_latency" = 1;
        "net.ipv4.tcp_notsent_lowat" = 1;
      };
      tmp.useTmpfs = false;
    };

    hardware.cpu.amd.updateMicrocode = config.hardware.amd.enable;
  };
}
