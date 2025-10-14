{ pkgs, ... }:

{
  environment.systemPackages = [
    # Used in wlx-overlay
    pkgs.kdePackages.kdialog
    pkgs.opencomposite
    pkgs.envision
    pkgs.wlx-overlay-s
    # Used in wlx-overlay
    pkgs.zenity
    pkgs.watchman-pairing-assistant
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
