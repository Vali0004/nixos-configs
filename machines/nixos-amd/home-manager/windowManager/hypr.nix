let
  hyprConfig = import ../../hyprconfig.nix;
in {
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
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
      monitor = [
        "DP-2, 2560x1440@240, 0x0, 1"
        "HDMI-A-1, 1920x1080, 2560x488, 1"
      ];
    };
    systemd.enable = true;
    xwayland.enable = true;
  };
}