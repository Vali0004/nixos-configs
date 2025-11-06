{ config, lib, pkgs, ... }:

{
  options.hardware.audio = {
    support32Bit = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable 32-bit support";
    };
    pipewire = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to enable Audio.";
      };
      enablePulse = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to enable Pipewire's PulseAudio backwards compatability (recommended)";
      };
    };
    pulseaudio = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to enable Audio.";
      };
    };
  };

  config = {
    services.pipewire = {
      enable = config.hardware.audio.pipewire.enable;
      alsa = {
        enable = true;
        support32Bit = config.hardware.audio.support32Bit;
      };
      pulse.enable = config.hardware.audio.pipewire.enablePulse;
      wireplumber = lib.mkIf config.hardware.bluetooth.enable {
        configPackages = [
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
    };

    environment.systemPackages = with pkgs; lib.optionals config.hardware.audio.pipewire.enable [
      # PulseAudio Volume Control
      pavucontrol
      # PipeWire/ALSA patchbay
      helvum
      # ALSA Utilities
      alsa-utils
      # PulseAudio Mixer - Used in several scripts for audio control
      pamixer
    ] ++ lib.optionals config.hardware.audio.pulseaudio.enable [
      # PulseAudio Volume Control
      pavucontrol
      # PulseAudio Mixer
      pamixer
    ];

    services.pulseaudio = {
      enable = config.hardware.audio.pulseaudio.enable;
      support32Bit = config.hardware.audio.support32Bit;
      extraConfig = lib.strings.optionalString config.hardware.bluetooth.enable ''
        load-module module-bluetooth-policy
        load-module module-bluetooth-discover
      '';
    };
  };
}
