{ config, lib, pkgs, ... }:

let
  discord_startup = pkgs.writeScriptBin "discord_startup" ''
    #!/bin/sh

    APP="discord"
    LOCKFILE="/tmp/.dwm-first-launch-$APP"
    TAG=3

    # Launch Discord (in background)
    $APP &

    if [ ! -f "$LOCKFILE" ]; then
        touch "$LOCKFILE"

        # Wait for real Discord window (not the Updater)
        for i in $(seq 1 20); do
            WIN_ID=$(xdotool search --onlyvisible --class discord | while read id; do
                name=$(xdotool getwindowname "$id" 2>/dev/null)
                if [ "$name" != "Discord Updater" ]; then
                    echo "$id"
                    break
                fi
            done)

            if [ -n "$WIN_ID" ]; then
                dwm-msg run_command "tag $((1 << TAG))"
                dwm-msg run_command "view $((1 << TAG))"
                break
            fi

            sleep 0.5
        done
    fi
  '';

  launch_once = pkgs.writeScriptBin "launch_once" ''
    #!/bin/sh
    APP="$1"
    TAG="$2"

    if [ -z "$APP" ] || [ -z "$TAG" ]; then
        echo "Usage: $0 <app> <tag (0-based index)>"
        exit 1
    fi

    LOCKFILE="/tmp/.dwm-first-launch-''${APP}"

    if [ ! -f "$LOCKFILE" ]; then
        # First launch: switch to target tag and run the app there
        dwm-msg run_command "view $((1 << TAG))"
        sleep 0.5
        "$APP" &
        touch "$LOCKFILE"
    else
        # Launch normally
        "$APP" &
    fi
  '';
in {
  home = {
    file.".local/share/dwm/discord_startup.sh".source = ''
      ${discord_startup}/bin/discord_startup
    '';
    file.".local/share/dwm/cider_launch_once.sh".source = ''
      ${launch_once}/bin/launch_once launch_once Cider 4
    '';
  };
}