{ ... }:

let
  hyprConfig = import ../../hyprconfig.nix;
in {
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      env = [
        "QT_QPA_PLATFORMTHEME, lxqt"
        "QT_PLATFORM_PLUGIN, lxqt"
        "XDG_MENU_PREFIX, lxqt-"
      ];

      exec-once = [
        # Start the LXQt session and exit when it finishes
        "lxqt-session && hyprctl dispatch exit"
      ];

      bind = [
        # Applications
        "${hyprConfig.modifier}, Return, exec, ${hyprConfig.wmAppTerminal}"
        "${hyprConfig.smodifier}, Return, exec, ${hyprConfig.wmAppBrowser}"
        "${hyprConfig.modifier}, D, exec, ${hyprConfig.wmAppLauncher}"
        "${hyprConfig.modifier}, V, exec, ${hyprConfig.wmClipboardManager}"
        "${hyprConfig.modifier}, Q, killactive,"
        "${hyprConfig.modifier}, M, exit,"
        "${hyprConfig.smodifier}, F, togglefloating,"
        "${hyprConfig.modifier}, E, togglesplit,"

        # Scratchpad workspace
        "${hyprConfig.modifier}, S, togglespecialworkspace, magic"
        "${hyprConfig.modifier} SHIFT, S, movetoworkspace, special:magic"

        # Scroll through existing workspaces with modifier + scroll
        "${hyprConfig.modifier}, mouse_down, workspace, e+1"
        "${hyprConfig.modifier}, mouse_up, workspace, e-1"

        # LXQt-specific bindings
        "Alt, F2, exec, lxqt-runner"
        "Alt, SPACE, exec, lxqt-runner"
        ", F12, exec, qterminal -d"
        ", XF86PowerOff, exec, lxqt-leave"
        "SUPER, L, exec, lxqt-leave --lockscreen"
        "bindr = SUPER, Super_L, exec, qdbus org.kde.StatusNotifierWatcher /global_key_shortcuts/panel/fancymenu/show_hide org.lxqt.global_key_shortcuts.client.activated"
      ] ++ (
        # Workspaces
        # Binds $smodifier + [shift +] {1..9} to [move to] workspace {1..9}
        builtins.concatLists (builtins.genList (i:
          let ws = i + 1;
          in [
            "${hyprConfig.modifier}, code:1${toString i}, workspace, ${toString ws}"
            "${hyprConfig.smodifier}, code:1${toString i}, movetoworkspace, ${toString ws}"
          ]
        ) 9)
      );

      bindm = [
        "${hyprConfig.modifier}, mouse:272, movewindow"
        "${hyprConfig.modifier}, mouse:273, resizewindow"
      ];

      windowrule = [
        "float,class:^(lxqt-.*|pavu.*|.*copyq|sddm-conf|qarma|.*portal-lxqt)$"
        "tile,class:lxqt-archiver"
        "float,title:^(.*Preferen.*)$"
        "dimaround,floating:1"
      ];

      layerrule = [
        "noanim, launcher"
        "dimaround, ^(launcher|dialog|dropdown_terminal)$"
        "animation slide top, dropdown_terminal"
        "animation popin 80%, dialog"
      ];

      animations = {
        enabled = true;
        bezier = [
          "easeOutQuint,0.23,1,0.32,1"
          "easeInOutCubic,0.65,0.05,0.36,1"
          "linear,0,0,1,1"
          "almostLinear,0.5,0.5,0.75,1.0"
          "quick,0.15,0,0.1,1"
        ];
        animation = [
          "global, 1, 10, default"
          "border, 1, 5.39, easeOutQuint"
          "windows, 1, 4.79, easeOutQuint"
          "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
          "windowsOut, 1, 1.49, linear, popin 87%"
          "fadeIn, 1, 1.73, almostLinear"
          "fadeOut, 1, 1.46, almostLinear"
          "fade, 1, 3.03, quick"
          "layers, 1, 3.81, easeOutQuint"
          "layersIn, 1, 4, easeOutQuint, fade"
          "layersOut, 1, 1.5, linear, fade"
          "fadeLayersIn, 1, 1.79, almostLinear"
          "fadeLayersOut, 1, 1.39, almostLinear"
          "workspaces, 1, 1.94, almostLinear, fade"
          "workspacesIn, 1, 1.21, almostLinear, fade"
          "workspacesOut, 1, 1.94, almostLinear, fade"
        ];
      };

      input = {
        kb_layout = "us";
        kb_options = "caps:super";
        follow_mouse = 1;
        sensitivity = 0;
      };

      bindel = [
        ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ",XF86MonBrightnessUp, exec, lxqt-config-brightness -i"
        ",XF86MonBrightnessDown, exec, lxqt-config-brightness -d"
      ];

      bindl = [
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPause, exec, playerctl play-pause"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPrev, exec, playerctl previous"
      ];

      monitor = [
        ",preferred,auto,1"
      ];

      # Disable update message
      ecosystem = {
        no_donation_nag = true;
        no_update_news = true;
      };
    };
  };
}