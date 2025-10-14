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
        # LXQt wallpaper
        "swaybg -i ${pkgs.lxqt-wayland-session}/share/lxqt/wallpapers/origami-dark.png"

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
    };
  };
}