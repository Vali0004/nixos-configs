self: super: {
  toxvpn = (builtins.getFlake "github:cleverca22/toxvpn/403586be0181a0b20dfc0802580f7f919aaa83de").packages.x86_64-linux.default;
  dmenu = super.dmenu.overrideAttrs (old: {
    buildInputs = (old.buildInputs or []) ++ [ self.libspng ];
    src = super.fetchFromGitHub {
      owner = "Vali0004";
      repo = "dmenu-fork";
      rev = "f196431df570102b325ae9f3ec91f18dac98b357";
      hash = "sha256-c+RjBl4NxA5EkGyaUc8me6vtFcvG7Vu5NZpJ/sBKOuY=";
    };
    postPatch = ''
      ${old.postPatch or ""}
      sed -ri -e 's!\<(dmenu|dmenu_path_desktop|stest)\>!'"$out/bin"'/&!g' dmenu_run_desktop
      sed -ri -e 's!\<stest\>!'"$out/bin"'/&!g' dmenu_path_desktop
    '';
  });
  dwm = super.dwm.overrideAttrs (old: {
    buildInputs = old.buildInputs ++ [ super.yajl ];
    src = super.fetchFromGitHub {
      owner = "Vali0004";
      repo = "dwm-fork";
      rev = "5e7409b6aedd3d734e71e0dc118f88097928d253";
      hash = "sha256-arUDkaYLGFo3EOYIbf3m68+ajVi07vBsc0n7L6lWGv4=";
    };
  });
  dwmblocks = super.dwmblocks.overrideAttrs (old: {
    src = super.fetchFromGitHub {
      owner = "nimaaskarian";
      repo = "dwmblocks-statuscmd-multithread";
      rev = "6700e322431b99ffc9a74b311610ecc0bc5b460a";
      hash = "sha256-TfPomjT/Z4Ypzl5P5VcVccmPaY8yosJmMLHrGBA6Ycg=";
    };
  });
  monado = super.monado.overrideAttrs (old: {
    version = "unstable";
    patches = [];
    src = self.fetchFromGitLab {
      domain = "gitlab.freedesktop.org";
      owner = "monado";
      repo = "monado";
      rev = "1d8b80b735c5541b171e498784c1231a7768c25f";
      hash = "sha256-Uuee7iH+ioH0/vlvhjoqMVJyfMSbgIHAz2cdj9iO1+Y=";
    };
  });
  #rtorrent = super.rtorrent.overrideAttrs (old: {
  #  version = "0.15.6";
  #  src = self.fetchFromGitHub {
  #    owner = "rakshasa";
  #    repo = "rtorrent";
  #    rev = "v0.15.6";
  #    hash = "sha256-B/5m1JXdUpczUMNN4cy5p6YurjmRFxMQHG3cQFSmZSs=";
  #  };
  #});
  #libtorrent-rakshasa = super.libtorrent-rakshasa.overrideAttrs (old: {
  #  version = "0.15.6";
  #  src = self.fetchFromGitHub {
  #    owner = "rakshasa";
  #    repo = "libtorrent";
  #    rev = "v0.15.6";
  #    hash = "sha256-udEe9VyUzPXuCTrB3U3+XCbVWvfTT7xNvJJkLSQrRt4=";
  #  };
  #});
  speedtest = self.callPackage pkgs/speedtest {};
  xwinwrap = super.xwinwrap.overrideDerivation (old: {
    version = "v0.9";
    src = super.fetchFromGitHub {
      owner = "Vali0004";
      repo = "xwinwrap";
      rev = "373426eb95ca62dedad3d77833ccf649f98f489b";
      hash = "sha256-przCOyureolbPLqy80DuyQoGeQ7lbGIXeR1z26DvN/E=";
    };
  });
}