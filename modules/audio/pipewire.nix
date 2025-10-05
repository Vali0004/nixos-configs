{ config, lib, pkgs, ... }:

{
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
    wireplumber.configPackages = [
      (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/10-bluez.conf" ''
        monitor.bluez.properties = {
          bluez5.roles = [ a2dp_sink a2dp_source bap_sink bap_source hsp_hs hsp_ag hfp_hf hfp_ag ]
          bluez5.codecs = [ sbc sbc_xq aac ]
          bluez5.enable-sbc-xq = true
          bluez5.enable-msbc = true
          bluez5.hfphsp-backend = "native"
        };
      '')
    ];
  };

  services.pulseaudio = {
    enable = false;
    support32Bit = true;
    extraConfig = ''
      load-module module-bluetooth-policy
      load-module module-bluetooth-discover
    '';
  };
}
