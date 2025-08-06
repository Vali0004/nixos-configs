{ config, lib, pkgs, ... }:

{
  services.picom = {
    activeOpacity = 1;
    backend = "glx";
    enable = true;
    fade = true;
    inactiveOpacity = 0.85;
    settings = {
      blur = {
        background = true;
        background-fixed = false;
        background-frame = false;
        direction = 30;
        method = "gaussian";
        strength = 30;
      };
      blur-background-exclude = [
        "class_g = 'Google-chrome'"
        "class_g = 'discord'"
        "class_g = 'flameshot'"
        "class_g = 'steam_app_727'"
      ];
      corner-radius = 10.0;
      detect-rounded-corners = true;
      rounded-corners-exclude = [
        "class_g = 'dwm'"
        "class_g = 'dmenu'"
      ];
      fading = true;
      fade-in-step = 1;
      fade-out-step = 1;
      opacity-rule = [
        "85:class_g = 'Code'"
        "95:class_g = 'Alacritty'"
        "100:class_g = 'Google-chrome'"
        "100:class_g = 'discord'"
        "100:class_g = 'flameshot'"
        "100:class_g = 'steam_app_727'"
      ];
      round-borders = 10;
      shadow-exclude = [
        "argb && (override_redirect || wmwin)"
      ];
      use-damage = true;
    };
    shadow = true;
    vSync = false;
    wintypes = {
      dnd.shadow = false;
      dock.clip-shadow-above = true;
      dock.shadow = false;
      dropdown_menu.opacity = 0.8;
      menu.shadow = false;
      popup_menu.opacity = 0.8;
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
