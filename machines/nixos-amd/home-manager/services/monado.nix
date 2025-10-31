{ config
, pkgs
, ... }:

{
  home.file = {
    # OpenXR discovery
    ".config/openxr/1/active_runtime.json".source = "${pkgs.monado}/share/openxr/1/openxr_monado.json";
    ".config/openvr/openvrpaths.vrpath".text = builtins.toJSON {
      config = [ "${config.xdg.dataHome}/Steam/config" ];
      external_drivers = null;
      jsonid = "vrpathreg";
      log = [ "${config.xdg.dataHome}/Steam/logs" ];
      runtime = [ "${pkgs.opencomposite}/lib/opencomposite" ];
      version = 1;
    };
    # Hand tracking models (otherwise monado will crash)
    ".local/share/monado/hand-tracking-models".source = pkgs.fetchgit {
      url = "https://gitlab.freedesktop.org/monado/utilities/hand-tracking-models";
      sha256 = "sha256-x/X4HyyHdQUxn3CdMbWj5cfLvV7UyQe1D01H93UCk+M=";
      fetchLFS = true;
    };
  };
}