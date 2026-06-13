self: super: {
  toxvpn = (builtins.getFlake "github:cleverca22/toxvpn/403586be0181a0b20dfc0802580f7f919aaa83de").packages.x86_64-linux.default;
  dmenu = super.dmenu.overrideAttrs (old: {
    buildInputs = (old.buildInputs or []) ++ [ super.libspng ];
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
    buildInputs = old.buildInputs ++ [
      super.yajl
      super.libxcomposite
      super.libxdamage
    ];
    #src = /home/vali/development/suckless-projects/dwm;
    src = super.fetchFromGitHub {
      owner = "Vali0004";
      repo = "dwm-fork";
      rev = "546655a74c6a472c0fd05e4306a16eb650da5901";
      hash = "sha256-3Im+9ZOX3ttJ8CkG9r5BxWht+rkObWpg0v2V9iq/4Sw=";
      #hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    };
  });
  dwmblocks = super.callPackage pkgs/dwmblocks {};
  llama-cpp = super.callPackage pkgs/llama-cpp {};
  rtorrent = super.rtorrent.overrideAttrs (old: finalAttrs: {
    version = "0.15.6";
    src = self.fetchFromGitHub {
      owner = "rakshasa";
      repo = "rtorrent";
      rev = "v${finalAttrs.version}";
      hash = "sha256-B/5m1JXdUpczUMNN4cy5p6YurjmRFxMQHG3cQFSmZSs=";
    };
  });
  libtorrent-rakshasa = super.libtorrent-rakshasa.overrideAttrs (old: finalAttrs: {
    version = "0.15.6";
    src = self.fetchFromGitHub {
      owner = "rakshasa";
      repo = "libtorrent";
      rev = "v${finalAttrs.version}";
      hash = "sha256-udEe9VyUzPXuCTrB3U3+XCbVWvfTT7xNvJJkLSQrRt4=";
    };
  });
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