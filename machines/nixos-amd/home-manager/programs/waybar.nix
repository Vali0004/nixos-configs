{ config, lib, pkgs, ... }:

let
  hyprConfig = import ../../hyprconfig.nix;
in {
  programs.waybar = {
    enable = true;
    settings =  {
      mainBar = {
        layer = "top";
        position = "top";
        mode = "dock";
        modules-left = [ "tray" "hyprland/workspaces" "hyprland/submap" ];
        modules-center = [ "wlr/taskbar" ];
        modules-right = [ "clock" ];
        "clock" = {
          calendar = {
            mode = "year";
            mode-mon-col = 3;
            weeks-pos = "right";
            on-scroll = 1;
            format = {
              months = "<span color='#ffead3'><b>{}</b></span>";
              days = "<span color='#ecc6d9'><b>{}</b></span>";
              weeks = "<span color='#99ffdd'><b>W{}</b></span>";
              weekdays = "<span color='#ffcc66'><b>{}</b></span>";
              today = "<span color='#ff6699'><b><u>{}</u></b></span>";
            };
            actions = {
              on-click-right = "mode";
              on-scroll-up = "shift_up";
              on-scroll-down = "shift_down";
            };
          };
          interval = 1;
          format = "{:%I:%M:%S %p}  ";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
        };
        "tray" = {
          spacing = 10;
        };
        "hyprland/workspaces" = {
          window-resize = {};
          disable-scroll = true;
        };
        "sway/window" = {
          format = "{app_id}";
          icon = true;
        };
        "cpu" = {
          format = "CPU: {usage}% ";
          tooltip = false;
          on-click = "missioncenter";
        };
        "memory" = {
          format = "{used:0.1f} GB / {total:0.1f} GB ";
          on-click = "missioncenter";
        };
        "wlr/taskbar" = {
          format = "{icon}";
          icon-size = 18;
          spacing = 0;
          tooltip-format = "{title}";
          on-click = "minimize-raise";
          on-click-right = "close";
        };
      };
    };
    style = ./style.css;
    systemd.enable = true;
  };
}