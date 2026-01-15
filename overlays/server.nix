self: super: {
  cors-anywhere = self.callPackage pkgs/cors-anywhere {};
  kursu-dev-status = self.callPackage pkgs/kursu-dev-status {};
  routerd = self.callPackage pkgs/routerd {};
  rtorrent-exporter = self.callPackage pkgs/rtorrent-exporter {};
}