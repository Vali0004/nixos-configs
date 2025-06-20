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
    '';
    package = pkgs.dwm.overrideAttrs {
      buildInputs = (pkgs.dwm.buildInputs or []) ++ [ pkgs.yajl ];
      src = pkgs.fetchFromGitHub {
        owner = "Vali0004";
        repo = "dwm-fork";
        rev = "755c8d500d635e67c3e2550f66770c43b2fd4cc9";
        hash = "sha256-PpwlqDbMy96v5kzDkm43+ldVTV9WysPiEYzlacmoonQ=";
      };
    };
  };
}
