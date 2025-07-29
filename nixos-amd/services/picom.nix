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
        background-fixed = true;
        background-frame = true;
        direction = 30;
        method = "gaussian";
        strength = 30;
      };
      blur-background-exclude = [
        "_NET_WM_WINDOW_TYPE@:32a *= '_NET_WM_WINDOW_TYPE_DOCK'"
        "class_g = 'Google-chrome'"
        "class_g = 'discord'"
        "class_g = 'flameshot'"
        "class_g = 'steam_app_727'"
      ];
      corner-radius = 10.0;
      detect-rounded-corners = true;
      refresh-rate = 240;
      rounded-corners-exclude = [
        "_NET_WM_WINDOW_TYPE@:32a *= '_NET_WM_WINDOW_TYPE_DOCK'"
        "class_g = 'dwm'"
      ];
      fading = true;
      fade-in-step = 0.08;
      fade-out-step = 0.08;
      fade-delta = 0;
      opacity-rule = [
        "100:_NET_WM_WINDOW_TYPE@:32a *= '_NET_WM_WINDOW_TYPE_DOCK'"
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
    shadow = false;
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
