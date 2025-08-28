{ config, pkgs, ... }:

{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;
    nvidiaSettings = true;
    open = false;
    package = hconfig.boot.kernelPackages.nvidiaPackages_570;
    powerManagement = {
      enable = false;
      finegrained = false;
    };
    prime.nvidiaBusId = "PCI:9:0:0";
  };

  services.xserver.videoDrivers = [ "nvidia" ];
}