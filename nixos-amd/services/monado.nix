{ config, lib, pkgs, ... }:

let
  openhmdFlake = builtins.getFlake "github:Vali0004/OpenHMD/c56529c22618325dfc31e7c44f17e804cb7e7edf";
  openhmdPkgs = openhmdFlake.outputs.packages.x86_64-linux;
  monado = pkgs.monado.override { openhmd = openhmdPkgs.openhmd; };
in {
  environment.systemPackages = [
    pkgs.opencomposite
    pkgs.wlx-overlay-s
  ];

  services.monado = {
    package = monado;
    defaultRuntime = true;
    enable = true;
    highPriority = true;
  };

  systemd.user.services.monado.environment = {
    STEAMVR_LH_ENABLE = "1";
    XRT_COMPOSITOR_COMPUTE = "1";
    WMR_HANDTRACKING = "0";
    XRT_DEBUG_GUI = "0";
  };
}
