{ config, lib, pkgs, ... }:

let
  xwinwrap_gif = pkgs.writeScriptBin "xwinwrap_gif" ''
    if [ $# -ne 1 ]; then
      echo 1>&2 Usage: $0 image.gif
      exit 1
    fi

    PIDFILE="/var/run/user/$UID/bg.pid"

    declare -a PIDs

    screen() {
      xwinwrap -ov -ni -g "$1" -- mpv --fullscreen\
          --no-stop-screensaver \
          --vo=vdpau --hwdec=vdpau \
          --loop-file --no-audio --no-osc --no-osd-bar -wid %WID --no-input-default-bindings \
          "$2" &
      PIDs+=($!)
    }

    while read p; do
      [[ $(ps -p "$p" -o comm=) == "xwinwrap" ]] && kill -9 "$p";
    done < $PIDFILE

    sleep 0.5

    for i in $( xrandr -q | grep ' connected' | grep -oP '\d+x\d+\+\d+\+\d+')
    do
      screen "$i" "$1"
    done

    printf "%s\n" "$\{PIDs[@]}" > $PIDFILE
  '';

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
  environment.systemPackages = with pkgs; [
    (polybar.override {
      alsaSupport = true;
      pulseSupport = true;
      iwSupport = true;
      i3Support = true;
    })
    gifsicle
    (xwinwrap.overrideDerivation (old: {
      version = "v0.9";
      src = pkgs.fetchFromGitHub {
        owner = "Vali0004";
        repo = "xwinwrap";
        rev = "373426eb95ca62dedad3d77833ccf649f98f489b";
        hash = "sha256-przCOyureolbPLqy80DuyQoGeQ7lbGIXeR1z26DvN/E=";
      };
    }))
    polybar-pulseaudio-control
  ];
  services.xserver.windowManager.dwm = {
    enable = true;
    extraSessionCommands = ''
      ${pkgs.pulseaudio}/bin/pactl set-default-sink "alsa_output.usb-SteelSeries_SteelSeries_Arctis_1_Wireless-00.analog-stereo"
      ${xwinwrap_gif}/bin/xwinwrap_gif /home/vali/wallpaper.gif
      ${discord_startup}/bin/discord_startup
      ${launch_once}/bin/launch_once Cider 4
    '';
    package = pkgs.dwm.overrideAttrs {
      buildInputs = (pkgs.dwm.buildInputs or []) ++ [ pkgs.yajl ];
      src =
      #./../../../../dwm;
      pkgs.fetchFromGitHub {
        owner = "Vali0004";
        repo = "dwm-fork";
        rev = "f389b8f665a6e3f4a7b8df13c0d83b74fd8b239a";
        hash = "sha256-hTSB4lJR7319rwigZO8+inGaUmV09DRCrUJXeIlaARE=";
      };
    };
  };
}
