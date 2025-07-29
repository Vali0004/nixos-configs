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
 dwmblocks = ((pkgs.dwmblocks.override {
    conf = ./dwmblocks-config.h;
  }).overrideAttrs {
    src = pkgs.fetchFromGitHub {
      owner = "nimaaskarian";
      repo = "dwmblocks-statuscmd-multithread";
      rev = "6700e322431b99ffc9a74b311610ecc0bc5b460a";
      hash = "sha256-TfPomjT/Z4Ypzl5P5VcVccmPaY8yosJmMLHrGBA6Ycg=";
    };
  });
in {
  environment.systemPackages = with pkgs; [
    libnotify
    gifsicle
    dwmblocks
    (xwinwrap.overrideDerivation (old: {
      version = "v0.9";
      src = pkgs.fetchFromGitHub {
        owner = "Vali0004";
        repo = "xwinwrap";
        rev = "373426eb95ca62dedad3d77833ccf649f98f489b";
        hash = "sha256-przCOyureolbPLqy80DuyQoGeQ7lbGIXeR1z26DvN/E=";
      };
    }))
  ];
  services.xserver.windowManager.dwm = {
    enable = true;
    extraSessionCommands = ''
      ${pkgs.pulseaudio}/bin/pactl set-default-sink "alsa_output.usb-SteelSeries_SteelSeries_Arctis_1_Wireless-00.analog-stereo"
      ${xwinwrap_gif}/bin/xwinwrap_gif /home/vali/.config/xwinwrap/wallpaper.gif
      ${dwmblocks}/bin/dwmblocks &
    '';
    package = pkgs.dwm.overrideAttrs {
      buildInputs = (pkgs.dwm.buildInputs or []) ++ [ pkgs.yajl ];
      src = /home/vali/development/dwm;
      #pkgs.fetchFromGitHub {
      #  owner = "Vali0004";
      #  repo = "dwm-fork";
      #  rev = "4cf2d04feade6e1a139b4fbe2ea16fa6d9f7290a";
      #  hash = "sha256-DjSz01jwFCXfxVxz0ITDn8vEuxE1rAjTiAvdcVGtMyc=";
      #};
    };
  };
  services.displayManager.defaultSession = "none+dwm";
}