{ config, lib, pkgs, ... }:

{
  options.hardware.bluetooth = {
    enableXboxControllerSupport = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable Xbox Controller Support or not.";
    };
  };

  config = lib.mkIf config.hardware.bluetooth.enable {
    boot = lib.mkIf config.hardware.bluetooth.enableXboxControllerSupport {
      extraModulePackages = [
        config.boot.kernelPackages.xone
      ];
      extraModprobeConfig = ''
        options bluetooth disable_ertm=Y
      '';
    };

    hardware.bluetooth = {
      package = pkgs.bluez;
      powerOnBoot = true;
      settings.General = {
        Privacy = "device";
        JustWorksRepairing = "always";
        Class = "0x000100";
        FastConnectable = true;
      };
    };

    services.avahi.enable = true;
    services.blueman.enable = true;
  };
}
