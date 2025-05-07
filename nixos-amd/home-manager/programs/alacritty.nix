{ config, lib, ... }:

{
  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        normal = {
          family = "DejaVu SansM Nerd Font";
        };
        size = 11.5;
      };
      mouse.bindings = [
        {
          mouse = "Right";
          action = "Paste";
        }
      ];
      selection.save_to_clipboard = true;
      window = {
        opacity = 1;
        blur = false;
      };
    };
  };
}
