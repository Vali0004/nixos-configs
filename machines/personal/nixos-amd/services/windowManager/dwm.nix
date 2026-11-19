{ pkgs
, ... }:

let
  dmenu_wrapper = pkgs.writeScriptBin "dmenu" ''
    ${pkgs.rofi}/bin/rofi -dmenu
  '';

  # relaunch dwm on crash or pkill, a clean quit (exit 0) still ends the session
  dwm_respawn = pkgs.symlinkJoin {
    name = "dwm-respawn";
    paths = [ pkgs.dwm ];
    postBuild = ''
      rm $out/bin/dwm
      cat > $out/bin/dwm <<EOS
    #!${pkgs.runtimeShell}
    until ${pkgs.dwm}/bin/dwm "\$@"; do sleep 0.5; done
    EOS
      chmod +x $out/bin/dwm
    '';
  };
in {
  imports = [
    ../../../../../modules/environment/dwmblocks.nix
    ../../../../../modules/services/x11-screenshot-portal.nix
  ];

  environment.systemPackages = with pkgs; [
    # App launcher
    dmenu_wrapper
    # dwm status
    dwmblocks
    # Gifsicle, used to split & optimize GIFS
    gifsicle
    # dwm ipc
    libnotify
    # X Window Wrap
    xwinwrap
    xwinwrap-gif
    # X Do Tool
    xdotool
  ];

  services.xserver.windowManager.dwm = {
    enable = true;
    package = dwm_respawn;
    extraSessionCommands = ''
      ${pkgs.pipewire}/bin/pw-metadata -n settings 0 default.audio.sink alsa_output.usb-Sony_INZONE_H9_II-00.analog-stereo
      ${pkgs.xwinwrap-gif}/bin/xwinwrap-gif /home/vali/.config/xwinwrap/wallpaper.mp4 &
      ${pkgs.dwmblocks}/bin/dwmblocks &
    '';
  };

  services.displayManager.defaultSession = "none+dwm";
}
