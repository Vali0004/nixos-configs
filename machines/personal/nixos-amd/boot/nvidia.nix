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
    # P100 (GP100) is 6.0, V100 (GV100) is 7.0. Both have to be listed
    # explicitly: nixpkgs' default capability list starts at 7.5, so leaving
    # this unset builds no kernels either card can run. CUDA 13 dropped Pascal
    # and Volta outright, so cudaPackages must stay on 12.x - 12.9 is the
    # current default, which is why nothing pins it here.
    cudaCapabilities = [ "6.0" "7.0" ];
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