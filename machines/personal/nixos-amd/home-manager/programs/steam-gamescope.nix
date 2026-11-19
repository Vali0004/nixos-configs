{ pkgs
, ... }:

let
  # start steam nested in gamescope, so games and their tray icons stay out of dwm
  # if steam already runs, just hand the args (steam:// urls) to it
  steam_gamescope = pkgs.writeShellScript "steam-gamescope" ''
    if ${pkgs.procps}/bin/pgrep -u "$USER" -x steam >/dev/null; then
      exec steam "$@"
    fi
    exec gamescope -e -f -W 2560 -H 1440 -r 240 -- steam "$@"
  '';
in {
  # same id as the system steam.desktop, the user copy wins for rofi and steam:// links
  xdg.desktopEntries.steam = {
    name = "Steam";
    genericName = "Game Library";
    exec = "${steam_gamescope} %U";
    icon = "steam";
    terminal = false;
    categories = [ "Network" "FileTransfer" "Game" ];
    mimeType = [ "x-scheme-handler/steam" "x-scheme-handler/steamlink" ];
  };
}
