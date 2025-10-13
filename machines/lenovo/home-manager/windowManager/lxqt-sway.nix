{ config, lib, pkgs, ... }:

let
  swayConfig = import ../../swayconfig.nix;
in {
  wayland.windowManager.sway = {
    enable = true;
    config = {
      # Bar
      bars = [{
        hiddenState = "hide";
        mode = "hide";
        extraConfig = ''
          swaybar_command = ""
          status_command = ""
        '';
      }];
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
      floating.modifier = swayConfig.modifier;
      # Keys
      keybindings = {
        #  Applications
        # Start a terminal
        "${swayConfig.modifier}+Return" = "exec ${swayConfig.wmAppTerminal}";
        # Start a program launcher
        "${swayConfig.modifier}+d" = "exec ${swayConfig.wmAppLauncher}";
        # Start a web browser
        "${swayConfig.modifier}+${swayConfig.smodifier}+Return" = "exec ${swayConfig.wmAppBrowser}";
        # Start the clipboard manager
        "${swayConfig.modifier}+v" = "exec ${swayConfig.wmClipboardManager}";
        # Kill focused window
        "${swayConfig.modifier}+q" = "kill";
        # LXQt Binds
        "alt+space" = "exec lxqt-runner";
        "alt+F2" = "exec lxqt-runner";
        "${swayConfig.modifier}+p" = "exec nemo";
        "${swayConfig.modifier}+${swayConfig.smodifier}+escape" = "exec lxqt-leave --lockscreen";
        "XF86PowerOff" = "exec lxqt-leave";
        "XF86MonBrightnessDown" = "exec lxqt-config-brightness -d";
        "XF86MonBrightnessUp" = "exec lxqt-config-brightness -i";
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
        "${swayConfig.modifier}+j" = "focus left";
        "${swayConfig.modifier}+Left" = "focus left";
        "${swayConfig.modifier}+k" = "focus down";
        "${swayConfig.modifier}+Down" = "focus down";
        "${swayConfig.modifier}+i" = "focus up";
        "${swayConfig.modifier}+Up" = "focus up";
        "${swayConfig.modifier}+l" = "focus right";
        "${swayConfig.modifier}+Right" = "focus right";
        # Move focused window (Alternatively, you can use the cursor keys)
        "${swayConfig.modifier}+${swayConfig.smodifier}+j" = "move left";
        "${swayConfig.modifier}+${swayConfig.smodifier}+Left" = "move left";
        "${swayConfig.modifier}+${swayConfig.smodifier}+k" = "move down";
        "${swayConfig.modifier}+${swayConfig.smodifier}+Down" = "move down";
        "${swayConfig.modifier}+${swayConfig.smodifier}+i" = "move up";
        "${swayConfig.modifier}+${swayConfig.smodifier}+Up" = "move up";
        "${swayConfig.modifier}+${swayConfig.smodifier}+l" = "move right";
        "${swayConfig.modifier}+${swayConfig.smodifier}+Right" = "move right";
        # Split in horizontal orientation
        "${swayConfig.modifier}+h" = "split h";
        # Split in vertical orientation
        "${swayConfig.modifier}+n" = "split v";
        # Enter fullscreen mode for the focused container
        "${swayConfig.modifier}+f" = "fullscreen";
        # Toggle between tiling and floating
        "${swayConfig.modifier}+${swayConfig.smodifier}+f" = "floating toggle";
        # Change focus between tiling and floating windows
        "${swayConfig.modifier}+space" = "focus mode_toggle";
        # Change container layout (stacked, tabbed, toggle split)
        "${swayConfig.modifier}+s" = "layout stacking";
        "${swayConfig.modifier}+w" = "layout tabbed";
        "${swayConfig.modifier}+e" = "layout toggle split";
        # Focus the parent container
        "${swayConfig.modifier}+a" = "focus parent";
        # Focus the child container
        #"${swayConfig.modifier}+d" = "focus child"
        # Switch to workspace (${smodifier} moves focused containers to workspace)
        "${swayConfig.modifier}+0" = "workspace 10";
        "${swayConfig.modifier}+${swayConfig.smodifier}+0" = "move container to workspace 10";
        "${swayConfig.modifier}+1" = "workspace 1";
        "${swayConfig.modifier}+${swayConfig.smodifier}+1" = "move container to workspace 1";
        "${swayConfig.modifier}+2" = "workspace 2";
        "${swayConfig.modifier}+${swayConfig.smodifier}+2" = "move container to workspace 2";
        "${swayConfig.modifier}+3" = "workspace 3";
        "${swayConfig.modifier}+${swayConfig.smodifier}+3" = "move container to workspace 3";
        "${swayConfig.modifier}+4" = "workspace 4";
        "${swayConfig.modifier}+${swayConfig.smodifier}+4" = "move container to workspace 4";
        "${swayConfig.modifier}+5" = "workspace 5";
        "${swayConfig.modifier}+${swayConfig.smodifier}+5" = "move container to workspace 5";
        "${swayConfig.modifier}+6" = "workspace 6";
        "${swayConfig.modifier}+${swayConfig.smodifier}+6" = "move container to workspace 6";
        "${swayConfig.modifier}+7" = "workspace 7";
        "${swayConfig.modifier}+${swayConfig.smodifier}+7" = "move container to workspace 7";
        "${swayConfig.modifier}+8" = "workspace 8";
        "${swayConfig.modifier}+${swayConfig.smodifier}+8" = "move container to workspace 8";
        "${swayConfig.modifier}+9" = "workspace 9";
        "${swayConfig.modifier}+${swayConfig.smodifier}+9" = "move container to workspace 9";
        # Alt-Tab
        "${swayConfig.modifier}+Tab" = "workspace prev";
        # Alt-Shift-Tab
        "${swayConfig.modifier}+${swayConfig.smodifier}+Tab" = "workspace next";
        # Restart the configuration file
        "${swayConfig.modifier}+${swayConfig.smodifier}+c" = "reload";
        # Restart sway inplace (preserves your layout/session, can be used to upgrade sway)
        "${swayConfig.modifier}+${swayConfig.smodifier}+r" = "restart";
        # Exit sway (logs you out of your X session)
        "${swayConfig.modifier}+${swayConfig.smodifier}+e" = "exec \"swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -B 'Yes, exit sway' 'swaymsg exit'\"";
        # Resize window (You can also use the mouse)
        "${swayConfig.modifier}+r" = "mode resize";
        # Flameshot keybind
        "Print" = "exec flameshot_fuckk_lol";
        # Flameshot keybind
        "Control+Print" = "exec flameshot gui --accept-on-select --clipboard";
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
          "${swayConfig.modifier}+r" = "mode default";
        };
      };
      # Modifer keys
      modifier = "${swayConfig.modifier}";
      startup = [
        # For some unknown fucking reason, sway on NixOS (and NixOS only) defaults to ws10
        { command = "workspace 1"; always = false; }
        # LXQt panel
        { command = "lxqt-panel"; always = false; }
      ];
      # Window options
      window = {
        hideEdgeBorders = "both";
        commands = [
          { command = "floating enable, focus disable"; criteria.class = "xwinwrap"; }
          { command = "border pixel 0"; criteria.class = "^.*"; }
          { command = "floating enable"; criteria.class = "^lxqt-.*$"; }
          { command = "floating enable"; criteria.class = "cmst"; }
          { command = "floating enable"; criteria.class = "kvantummanager"; }
        ];
      };
    };
    extraConfig = ''
      focus_on_window_activation focus
    '';
  };
}
