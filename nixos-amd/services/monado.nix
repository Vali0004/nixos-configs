{ config, lib, pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.opencomposite
    pkgs.wlx-overlay-s
  ];

  services.monado = {
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
