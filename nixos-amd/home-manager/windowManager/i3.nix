{ config, lib, pkgs, ... }:

let
  i3Config = import ./../../i3config.nix;
in {
  xsession.windowManager.i3 = {
    enable = true;
    extraConfig = ''
      # For some unknown fucking reason, i3 on NixOS (and NixOS only) defaults to ws10
      exec --no-startup-id i3-msg "workspace 1"
      # Better layouts
      exec_always --no-startup-id i3-auto-layout
    '';
    config = {
      # Bar
      bars = [{
        hiddenState = "hide";
        mode = "hide";
        extraConfig = ''
          i3bar_command = ""
          status_command = ""
        '';
      }];
      # Colors
      colors = {
        focused = {
          border = "#0F0F0F";
          background = "#0F0F0F";
          text = "#FFFFFF";
          indicator = "#0F0F0F";
          childBorder = "#000000";
        };
        focusedInactive = {
          border = "#0F0F0F";
          background = "#0F0F0F";
          text = "#FFFFFF";
          indicator = "#0F0F0F";
          childBorder = "#000000";
        };
        unfocused = {
          border = "#3B3B3B";
          background = "#3B3B3B";
          text = "#FFFFFF";
          indicator = "#3B3B3B";
          childBorder = "#000000";
        };
        background = "#0F0F0F";
      };
      # Theme
      fonts = {
        names = [ "DejaVu Sans Mono 11" "FontAwesome5Free" ];
        style = "Regular";
        size = 11.0;
      };
      # Gaps
      gaps = {
        inner = 4;
        outer = 2;
        smartGaps = true;
      };
      # Use Mouse+$mod to drag floating windows to their wanted position
      floating.modifier = i3Config.modifier;
      # Keys
      keybindings = {
        #  Applications
        # Start a terminal
        "${i3Config.modifier}+Return" = "exec ${i3Config.wmAppTerminal}";
        # Start a program launcher
        "${i3Config.modifier}+d" = "exec ${i3Config.wmAppLauncher}";
        # Start a web browser
        "${i3Config.modifier}+${i3Config.smodifier}+Return" = "exec ${i3Config.wmAppBrowser}";
        # Start the clipboard manager
        "${i3Config.modifier}+v" = "exec ${i3Config.wmClipboardManager}";
        # Kill focused window
        "${i3Config.modifier}+q" = "kill";
        # Pipewire-pulse
        "XF86AudioMute" = "exec pactl set-sink-mute 0 toggle";
        "XF86AudioLowerVolume" = "exec pactl set-sink-volume 0 -5%";
        "XF86AudioRaiseVolume" = "exec pactl set-sink-volume 0 +5%";
        # Media player controls
        "XF86AudioPlay" = "exec playerctl play-pause";
        "XF86AudioPause" = "exec playerctl play-pause";
        "XF86AudioNext" = "exec playerctl next";
        "XF86AudioPrev" = "exec playerctl previous";
        # Change focus (Alternatively, you can use the cursor keys)
        "${i3Config.modifier}+j" = "focus left";
        "${i3Config.modifier}+Left" = "focus left";
        "${i3Config.modifier}+k" = "focus down";
        "${i3Config.modifier}+Down" = "focus down";
        "${i3Config.modifier}+i" = "focus up";
        "${i3Config.modifier}+Up" = "focus up";
        "${i3Config.modifier}+l" = "focus right";
        "${i3Config.modifier}+Right" = "focus right";
        # Move focused window (Alternatively, you can use the cursor keys)
        "${i3Config.modifier}+${i3Config.smodifier}+j" = "move left";
        "${i3Config.modifier}+${i3Config.smodifier}+Left" = "move left";
        "${i3Config.modifier}+${i3Config.smodifier}+k" = "move down";
        "${i3Config.modifier}+${i3Config.smodifier}+Down" = "move down";
        "${i3Config.modifier}+${i3Config.smodifier}+i" = "move up";
        "${i3Config.modifier}+${i3Config.smodifier}+Up" = "move up";
        "${i3Config.modifier}+${i3Config.smodifier}+l" = "move right";
        "${i3Config.modifier}+${i3Config.smodifier}+Right" = "move right";
        # Split in horizontal orientation
        "${i3Config.modifier}+h" = "split h";
        # Split in vertical orientation
        "${i3Config.modifier}+n" = "split v";
        # Enter fullscreen mode for the focused container
        "${i3Config.modifier}+f" = "fullscreen";
        # Toggle between tiling and floating
        "${i3Config.modifier}+${i3Config.smodifier}+f" = "floating toggle";
        # Change focus between tiling and floating windows
        "${i3Config.modifier}+space" = "focus mode_toggle";
        # Change container layout (stacked, tabbed, toggle split)
        "${i3Config.modifier}+s" = "layout stacking";
        "${i3Config.modifier}+w" = "layout tabbed";
        "${i3Config.modifier}+e" = "layout toggle split";
        # Focus the parent container
        "${i3Config.modifier}+a" = "focus parent";
        # Focus the child container
        #"${i3Config.modifier}+d" = "focus child"
        # Switch to workspace (${smodifier} moves focused containers to workspace)
        "${i3Config.modifier}+0" = "workspace 10";
        "${i3Config.modifier}+${i3Config.smodifier}+0" = "move container to workspace 10";
        "${i3Config.modifier}+1" = "workspace 1";
        "${i3Config.modifier}+${i3Config.smodifier}+1" = "move container to workspace 1";
        "${i3Config.modifier}+2" = "workspace 2";
        "${i3Config.modifier}+${i3Config.smodifier}+2" = "move container to workspace 2";
        "${i3Config.modifier}+3" = "workspace 3";
        "${i3Config.modifier}+${i3Config.smodifier}+3" = "move container to workspace 3";
        "${i3Config.modifier}+4" = "workspace 4";
        "${i3Config.modifier}+${i3Config.smodifier}+4" = "move container to workspace 4";
        "${i3Config.modifier}+5" = "workspace 5";
        "${i3Config.modifier}+${i3Config.smodifier}+5" = "move container to workspace 5";
        "${i3Config.modifier}+6" = "workspace 6";
        "${i3Config.modifier}+${i3Config.smodifier}+6" = "move container to workspace 6";
        "${i3Config.modifier}+7" = "workspace 7";
        "${i3Config.modifier}+${i3Config.smodifier}+7" = "move container to workspace 7";
        "${i3Config.modifier}+8" = "workspace 8";
        "${i3Config.modifier}+${i3Config.smodifier}+8" = "move container to workspace 8";
        "${i3Config.modifier}+9" = "workspace 9";
        "${i3Config.modifier}+${i3Config.smodifier}+9" = "move container to workspace 9";
        # Alt-Tab
        "${i3Config.modifier}+Tab" = "workspace prev";
        # Alt-Shift-Tab
        "${i3Config.modifier}+${i3Config.smodifier}+Tab" = "workspace next";
        # Restart the configuration file
        "${i3Config.modifier}+${i3Config.smodifier}+c" = "reload";
        # Restart i3 inplace (preserves your layout/session, can be used to upgrade i3)
        "${i3Config.modifier}+${i3Config.smodifier}+r" = "restart && exec \"polybar-msg cmd restart\"";
        # Exit i3 (logs you out of your X session)
        "${i3Config.modifier}+${i3Config.smodifier}+e" = "exec \"i3-nagbar -t warning -m 'You pressed the exit shortcut. Do you really want to exit i3? This will end your X session.' -B 'Yes, exit i3' 'i3-msg exit && polybar-msg exit'\"";
        # Resize window (You can also use the mouse)
        "${i3Config.modifier}+r" = "mode resize";
        # Flameshot keybind
        "Print" = "exec flameshot_fuckk_lol";
        # Flameshot keybind
        "Control+Print" = "exec ${pkgs.flameshot}/bin/flameshot gui --accept-on-select";
      };
      modes = {
        resize = {
          # These bindings trigger as soon as you enter the resize mod
          # Pressing up or i will shrink the window's height.
          "Up" = "resize shrink height 10 px or 10 ppt";
          "i" = "resize shrink height 10 px or 10 ppt";
          # Pressing down or kwill grow the window's height.
          "Down" = "resize grow height 10 px or 10 ppt";
          "k" = "resize grow height 10 px or 10 ppt";
          # Pressing left or j will shrink the window's width.
          "Left" = "resize shrink width 10 px or 10 ppt";
          "j" = "resize shrink width 10 px or 10 ppt";
          # Pressing right or l will grow the window's width.
          "Right" = "resize grow width 10 px or 10 ppt";
          "l" = "resize grow width 10 px or 10 ppt";
          # Back to normal: Enter, Escape, or ${modifier}+r
          "Escape" = "mode default";
          "Return" = "mode default";
          "${i3Config.modifier}+r" = "mode default";
        };
      };
      # Modifer keys
      modifier = "${i3Config.modifier}";
      # Window options
      window = {
        hideEdgeBorders = "both";
        commands = [
          {
            command = "border pixel 0";
            criteria = {
              class = "^.*";
            };
          }
        ];
      };
    };
  };
}
