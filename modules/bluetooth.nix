{ config, lib, pkgs, ... }:

{
  boot.extraModulePackages = [
    config.boot.kernelPackages.xone
  ];
  boot.extraModprobeConfig = ''
    options bluetooth disable_ertm=Y
  '';

  hardware.bluetooth = {
    enable = true;
    package = pkgs.bluez;
    powerOnBoot = true;
    settings.General = {
      Privacy = "device";
      JustWorksRepairing = "always";
      Class = "0x000100";
      FastConnectable = true;
    };
  };

  hardware.xpadneo.enable = false;

  services = {
    avahi.enable = true;
    blueman.enable = true;
  };
}
