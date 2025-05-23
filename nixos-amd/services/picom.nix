{ config, lib, pkgs, ... }:

{
  services.picom = {
    activeOpacity = 1;
    backend = "glx";
    enable = true;
    fade = true;
    inactiveOpacity = 0.8;
    settings = {
      blur = {
        background = false;
        background-fixed = false;
        background-frame = false;
        method = "dual_kawase";
        strength = 12;
      };
      blur-background-exclude = [
        "class_g = 'discord'"
        "class_g = 'Chrome'"
      ];
      corner-radius = 10.0;
      detect-rounded-corners = true;
      refresh-rate = 0;
      fading = true;
      fade-in-step = 0.08;
      fade-out-step = 0.08;
      #fade-delta = 0;
      opacity-rule = [
        "75:class_g = 'Code'"
      ];
      round-borders = 10;
      shadow-exclude = [
        "argb && (override_redirect || wmwin)"
      ];
      use-damage = true;
    };
    shadow = false;
    vSync = false;
    wintypes = {
      dnd = {
        shadow = false;
      };
      dock = {
        clip-shadow-above = true;
        shadow = false;
      };
      dropdown_menu = {
        opacity = 0.8;
      };
      menu = {
        shadow = false;
      };
      popup_menu = {
        opacity = 0.8;
      };
      tooltip = {
        fade = true;
        focus = true;
        full-shadow = false;
        opacity = 0.75;
        shadow = true;
      };
    };
  };
}
