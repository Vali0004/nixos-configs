{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # MPV Paper (xwinwrap mpv, for wlroots-compositors)
    mpvpaper
    # D(ynamic)Menu Replacment
    rofi
    # Wayland Clipboard
    wl-clipboard
    # Wayland Roots Randr (XRandr for wloots)
    wlr-randr
  ];

  programs = {
    mango.enable = true;
    xwayland.enable = true;
  };

  services.displayManager.defaultSession = "mango";
}