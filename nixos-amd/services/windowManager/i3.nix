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
  services.xserver.windowManager.i3 = {
    enable = true;
    extraPackages = with pkgs; [
      i3-auto-layout
      i3status
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
    #  ${pkgs.feh}/bin/feh --bg-center /home/vali/wallpaper.png
    extraSessionCommands = ''
      cp /run/sddm/xauth_* /home/vali/.Xauthority
      ${pkgs.pulseaudio}/bin/pactl set-default-sink "alsa_output.usb-SteelSeries_SteelSeries_Arctis_1_Wireless-00.analog-stereo"
      ${xwinwrap_gif}/bin/xwinwrap_gif /home/vali/.config/xwinwrap/wallpaper.gif
    '';
    package = pkgs.i3;
  };
  services.displayManager.defaultSession = "none+i3";
}
