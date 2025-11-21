{ config
, ... }:

{
  nixpkgs.config.permittedInsecurePackages = [
    # Required for agenix
    "libxml2-2.13.8"
    # Required for jellyfin-media-player
    "qtwebengine-5.15.19"
  ];

  nixpkgs.overlays = [
    # Custom pkgs
    (self: super: {
      beammp-launcher = self.callPackage ./beammp-launcher {};
      clipmenu-paste = self.callPackage ./clipmenu {};
      darling = self.callPackage ./darling {};
      dnspy = self.callPackage ./dnspy {};
      dwmblocks-battery = self.callPackage dwmblocks/battery {};
      dwmblocks-cpu = self.callPackage dwmblocks/cpu {};
      dwmblocks-memory = self.callPackage dwmblocks/memory {};
      dwmblocks-network = self.callPackage dwmblocks/network {};
      dwmblocks-playerctl = self.callPackage dwmblocks/playerctl {};
      fastfetch-simple = self.writeScriptBin "fastfetch-simple" ''
        ${self.fastfetch}/bin/fastfetch --config /home/vali/.config/fastfetch/simple.jsonc
      '';
      flameshot-upload = self.writeScriptBin "flameshot-upload" ''
        ${self.flameshot}/bin/flameshot gui --accept-on-select -r > /tmp/screenshot.png
        ${self.curl}/bin/curl -H $(${self.coreutils}/bin/cat /run/agenix/zipline-upload-headers) https://holy.fuckk.lol/api/upload -F file=@/tmp/screenshot.png -H 'content-type: multipart/form-data' | ${self.jq}/bin/jq -r .files[0].url | tr -d '\n' | ${self.xclip}/bin/xclip -selection clipboard
      '';
      ida-pro = self.callPackage ./ida-pro {};
      jlink = self.callPackage nordic/jlink {};
      manage-gnome-calculator = self.callPackage ./manage-gnome-calculator {};
      nrf-studio = self.callPackage ./nordic {};
      nrf-util = self.callPackage nordic/nrfutil {};
      osu-base = self.callPackage ./osu {
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
      xwinwrap-gif = self.callPackage ./xwinwrap {};
    })
  ];
}