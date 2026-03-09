{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Used in wlx-overlay
    kdePackages.kdialog
    opencomposite
    envision
    wlx-overlay-s
    wayvr-dashboard
    # Used in wlx-overlay
    zenity
    watchman-pairing-assistant
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