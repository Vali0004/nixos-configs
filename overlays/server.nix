self: super: {
  cors-anywhere = self.callPackage pkgs/cors-anywhere {};
  fuckk-lol-status = self.callPackage pkgs/fuckk-lol-status {};
  rtorrent-exporter = self.callPackage pkgs/rtorrent-exporter {};
}