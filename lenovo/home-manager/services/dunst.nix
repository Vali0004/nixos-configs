{ config, lib, ... }:

{
  services.dunst = {
    enable = true;
    settings = {
      global = {
        font = "DejaVu Sans Mono 11";
        origin = "top-right";
        scale = 1;
        transparency = 20;
      };
      urgency_normal = {
        background = "#37474f";
        foreground = "#eceff1";
        timeout = 10;
      };
    };
  };
}
