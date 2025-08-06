{ config, lib, pkgs, ... }:

let
  xwinwrap_gif = pkgs.writeScriptBin "xwinwrap_gif" ''
    if [ $# -ne 1 ]; then
      echo 1>&2 Usage: $0 image.gif
      exit 1
    fi

    PIDFILE="/var/run/user/$UID/bg.pid"

    # Ensure directory exists
    mkdir -p "$(dirname "$PIDFILE")"

    declare -a PIDs

    screen() {
      xwinwrap -ov -ni -g "$1" -- mpv --fullscreen\
          --no-stop-screensaver \
          --vo=vdpau --hwdec=vdpau \
          --loop-file --no-audio --no-osc --no-osd-bar -wid %WID --no-input-default-bindings \
          "$2" &
      PIDs+=($!)
    }

    if [ -f "$PIDFILE" ]; then
      while read -r p; do
        if [[ "$p" =~ ^[0-9]+$ ]]; then
          comm=$(ps -p "$p" -o comm= 2>/dev/null)
          if [[ "$comm" == "xwinwrap" ]]; then
            kill -9 "$p"
          fi
        fi
      done < "$PIDFILE"
    fi

    sleep 0.5

    for i in $(xrandr -q | grep ' connected' | grep -oP '\d+x\d+\+\d+\+\d+'); do
      screen "$i" "$1"
    done

    if [ "''${#PIDs[@]}" -gt 0 ]; then
      printf "%s\n" "''${PIDs[@]}" > "$PIDFILE"
    else
      > "$PIDFILE"
    fi
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
  dwm = with pkgs; pkgs.dwm.overrideAttrs(old: {
    buildInputs = old.buildInputs ++ [ yajl ];
    src = /home/vali/development/dwm;
    #pkgs.fetchFromGitHub {
    #  owner = "Vali0004";
    #  repo = "dwm-fork";
    #  rev = "4cf2d04feade6e1a139b4fbe2ea16fa6d9f7290a";
    #  hash = "sha256-DjSz01jwFCXfxVxz0ITDn8vEuxE1rAjTiAvdcVGtMyc=";
    #};
  });
  manage-gnome-calculator = pkgs.callPackage ./manage-gnome-calculator.nix { dwm = dwm; };
  dwmblocks-cpu = pkgs.callPackage ./dwmblocks-cpu.nix {};
  dwmblocks-memory = pkgs.callPackage ./dwmblocks-memory.nix {};
  dwmblocks-network = pkgs.callPackage ./dwmblocks-network.nix {};
  dwmblocks-playerctl = pkgs.callPackage ./dwmblocks-playerctl.nix {};
in {
  environment.etc = {
    "dwm/blocks/scripts/cpu".source = dwmblocks-cpu;
    "dwm/blocks/scripts/memory".source = dwmblocks-memory;
    "dwm/blocks/scripts/network".source = dwmblocks-network;
    "dwm/blocks/scripts/playerctl".source = dwmblocks-playerctl;
  };
  environment.systemPackages = with pkgs; [
    gifsicle # Needed for wallpaper
    dwmblocks # dwm status
    libnotify # dwm ipc
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
      ${xwinwrap_gif}/bin/xwinwrap_gif /home/vali/.config/xwinwrap/wallpaper.gif &
      ${dwmblocks}/bin/dwmblocks &
      ${manage-gnome-calculator} &
    '';
    package = dwm;
  };
  services.displayManager.defaultSession = "none+dwm";
}