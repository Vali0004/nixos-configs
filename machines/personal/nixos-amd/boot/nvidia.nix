{ config
, pkgs
, ... }:

let
  nvidiaPkg = config.boot.kernelPackages.nvidiaPackages.legacy_580;
in {
  boot = {
    blacklistedKernelModules = [ "nouveau" ];

    extraModulePackages = [
      nvidiaPkg.mod
    ];

    kernelModules = [
      "nvidia"
    ];
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = [ nvidiaPkg.out ];
  };

  nixpkgs.config = {
    nvidia.acceptLicense = true;
    cudaCapabilities = [ "6.0" ];
  };

  hardware.nvidia = {
    modesetting.enable = false;
    nvidiaSettings = true;
    open = false;
    package = nvidiaPkg;
    powerManagement = {
      enable = false;
      finegrained = false;
    };
    prime.nvidiaBusId = "PCI:9:0:0";
  };

  environment.systemPackages = [ nvidiaPkg.bin ];

  # Create /dev/nvidia* at boot; without X nothing else does it.
  systemd.services.nvidia-device-nodes = {
    description = "Create NVIDIA device nodes";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-modules-load.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = [
        "${pkgs.kmod}/bin/modprobe nvidia"
        "${pkgs.kmod}/bin/modprobe nvidia_uvm"
        "${nvidiaPkg.bin}/bin/nvidia-smi"
      ];
    };
  };
}