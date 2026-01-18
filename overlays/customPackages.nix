self: super: {
  beammp-launcher = self.callPackage pkgs/beammp-launcher {};
  clipmenu-paste = self.callPackage pkgs/clipmenu {};
  darling = self.callPackage pkgs/darling {};
  dnspy = self.callPackage pkgs/dnspy {};
  dwmblocks-battery = self.callPackage pkgs/dwmblocks/battery {};
  dwmblocks-cpu = self.callPackage pkgs/dwmblocks/cpu {};
  dwmblocks-memory = self.callPackage pkgs/dwmblocks/memory {};
  dwmblocks-network = self.callPackage pkgs/dwmblocks/network {};
  dwmblocks-playerctl = self.callPackage pkgs/dwmblocks/playerctl {};
  ida-pro = self.callPackage pkgs/ida-pro {};
  jlink = self.callPackage pkgs/nordic/jlink {};
  manage-gnome-calculator = self.callPackage pkgs/manage-gnome-calculator {};
  nrf-studio = self.callPackage pkgs/nordic {};
  nrf-util = self.callPackage pkgs/nordic/nrfutil {};
  onthespot = self.callPackage pkgs/onthespot {};
  osu-base = self.callPackage pkgs/osu {
    osu-mime = self.nixGaming.osu-mime;
    wine-discord-ipc-bridge = self.nixGaming.wine-discord-ipc-bridge;
    proton-osu-bin = self.nixGaming.proton-osu-bin;
  };
  osu-stable = self.osu-base;
  osu-gatari = self.osu-base.override {
    desktopName = "osu!gatari";
    pname = "osu-gatari";
    launchArgs = "-devserver gatari.pw";
  };
  patreon-dl-gui = self.callPackage pkgs/patreon-dl-gui {};
  routerd = self.callPackage pkgs/routerd {};
  surfboard-hnap-exporter = self.callPackage pkgs/surfboard-hnap-exporter {};
  xwinwrap-gif = self.callPackage pkgs/xwinwrap {};
}