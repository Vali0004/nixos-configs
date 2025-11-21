{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-xr = {
      url = "github:nix-community/nixpkgs-xr";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix.url = "github:ryantm/agenix";
    ajax-xdp.url = "/home/vali/development/ajax/ajax-xdp";
    skylanders-nfc-reader.url = "/home/vali/development/skylanders-nfc-reader";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    nix-gaming.url = "github:fufexan/nix-gaming";
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
    nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
    spicetify.url = "github:Gerg-L/spicetify-nix";
    watchman-pairing-assistant = {
      url = "github:TayouVR/watchman-pairing-assistant";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zfs-utils = {
      url = "github:cleverca22/zfs-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mangowc = {
      url = "github:DreamMaoMao/mangowc";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs@{ self, nixpkgs, nixpkgs-xr, agenix, ajax-xdp, home-manager, impermanence, mangowc, nix-gaming, nix-minecraft, nixos-mailserver, skylanders-nfc-reader, spicetify, watchman-pairing-assistant, zfs-utils }:
  let
    system = "x86_64-linux";
    coreImports = [
      agenix.nixosModules.age
      ./core.nix
    ];

    overlays = [
      nix-minecraft.overlay
      # Flake overrides
      (self: super: {
        eepyxr = nixpkgs-xr.packages.x86_64-linux.eepyxr;
        index_camera_passthrough = nixpkgs-xr.packages.x86_64-linux.index_camera_passthrough;
        kaon = nixpkgs-xr.packages.x86_64-linux.kaon;
        opencomposite = nixpkgs-xr.packages.x86_64-linux.opencomposite;
        opencomposite-vendored = nixpkgs-xr.packages.x86_64-linux.opencomposite-vendored;
        proton-ge-rtsp-bin = nixpkgs-xr.packages.x86_64-linux.proton-ge-rtsp-bin;
        vapor = nixpkgs-xr.packages.x86_64-linux.vapor;
        wayvr-dashboard = nixpkgs-xr.packages.x86_64-linux.wayvr-dashboard;
        wivrn = nixpkgs-xr.packages.x86_64-linux.wivrn;
        wlx-overlay-s = nixpkgs-xr.packages.x86_64-linux.wlx-overlay-s;
        xrizer = nixpkgs-xr.packages.x86_64-linux.xrizer;
        watchman-pairing-assistant = watchman-pairing-assistant.packages.x86_64-linux.default;

        agenix = agenix.outputs.packages.x86_64-linux.agenix;
        ajax-xdp = ajax-xdp.packages.x86_64-linux.default;
        speedtest = self.callPackage pkgs/speedtest {};
        cors-anywhere = self.callPackage pkgs/cors-anywhere {};
        fuckk-lol-status = self.callPackage pkgs/fuckk-lol-status {};
        patreon-dl-gui = self.callPackage pkgs/patreon-dl-gui {};
        forgeServers = {
          forge-1_7_10-10_13_4 = self.callPackage pkgs/nix-minecraft/forge { version = "1.7.10-10.13.4.16"; };
          forge-1_16_5-36_2_26 = self.callPackage pkgs/nix-minecraft/forge { version = "1.16.5-36.2.26"; };
          forge-1_16_5-36_2_39 = self.callPackage pkgs/nix-minecraft/forge { version = "1.16.5-36.2.39"; };
          forge-1_16_5-36_2_42 = self.callPackage pkgs/nix-minecraft/forge { version = "1.16.5-36.2.42"; };
          forge-1_18_2-40_3_0  = self.callPackage pkgs/nix-minecraft/forge { version = "1.18.2-40.3.0";  };
          forge-1_20_1-47_2_17 = self.callPackage pkgs/nix-minecraft/forge { version = "1.20.1-47.2.17"; };
          forge-1_20_1-47_3_0  = self.callPackage pkgs/nix-minecraft/forge { version = "1.20.1-47.3.0";  };
          forge-1_20_1-47_4_0  = self.callPackage pkgs/nix-minecraft/forge { version = "1.20.1-47.4.0";  };
        };
        mailserver = nixos-mailserver.x86_64-linux.default;
        prowlarr = self.callPackage pkgs/prowlarr {};
        nixGaming = nix-gaming.outputs.packages.x86_64-linux;
        skylanders-nfc-reader = skylanders-nfc-reader.outputs.packages.x86_64-linux.default;
        spicetifyThemes = spicetify.outputs.legacyPackages.x86_64-linux.themes;
        spicetifyExtensions = spicetify.outputs.legacyPackages.x86_64-linux.extensions;
        rtorrent-exporter = self.callPackage pkgs/rtorrent-exporter {};
        zfs-fragmentation = zfs-utils.packages.x86_64-linux.zfs-fragmentation;
      })
      # Existing pkgs
      (self: super: {
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
        rtorrent = super.rtorrent.overrideAttrs (old: {
          version = "0.15.6";
          src = self.fetchFromGitHub {
            owner = "rakshasa";
            repo = "rtorrent";
            rev = "v0.15.6";
            hash = "sha256-B/5m1JXdUpczUMNN4cy5p6YurjmRFxMQHG3cQFSmZSs=";
          };
        });
        libtorrent-rakshasa = super.libtorrent-rakshasa.overrideAttrs (old: {
          version = "0.15.6";
          src = self.fetchFromGitHub {
            owner = "rakshasa";
            repo = "libtorrent";
            rev = "v0.15.6";
            hash = "sha256-udEe9VyUzPXuCTrB3U3+XCbVWvfTT7xNvJJkLSQrRt4=";
          };
        });
        xwinwrap = super.xwinwrap.overrideDerivation (old: {
          version = "v0.9";
          src = super.fetchFromGitHub {
            owner = "Vali0004";
            repo = "xwinwrap";
            rev = "373426eb95ca62dedad3d77833ccf649f98f489b";
            hash = "sha256-przCOyureolbPLqy80DuyQoGeQ7lbGIXeR1z26DvN/E=";
          };
        });
        zfs = super.zfs.overrideAttrs (old: {
          src = self.fetchurl {
            url = "https://github.com/openzfs/zfs/archive/pull/14013/head.tar.gz";
            hash = "sha256-X4PO6uf/ppEedR6ZAoWmrDRfHXxv2LuBThekRZOwmoA=";
          };
          patches = [];
        });
      })
    ];

    pkgs = import nixpkgs { inherit system overlays; };
  in {
    colmena = {
      meta.nixpkgs = pkgs;
      router-vps = {
        deployment = {
          targetHost = "74.208.44.130";
          targetUser = "root";
          targetPort = 22;
        };
        imports = coreImports ++ [
          machines/router-vps/configuration.nix
        ];
      };
      router-vps-v2 = {
        deployment = {
          targetHost = "23.143.108.18";
          targetUser = "root";
          targetPort = 22;
        };
        imports = coreImports ++ [
          machines/router-vps-v2/configuration.nix
        ];
      };
      shitzen-nixos = {
        deployment = {
          targetHost = "10.0.0.229";
          targetUser = "root";
          targetPort = 22;
        };
        imports = coreImports ++ [
          nix-minecraft.nixosModules.minecraft-servers
          nixos-mailserver.nixosModule
          machines/shitzen-nixos/configuration.nix
        ];
      };
      #nixos-router = {
      #  deployment = {
      #    targetHost = "10.0.0.229";
      #    targetUser = "root";
      #    targetPort = 22;
      #  };
      #  imports = coreImports ++ [
      #    machines/nixos-router/configuration.nix
      #  ];
      #};
    };

    nixosConfigurations = {
      nixos-amd = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs overlays; };
        modules = [
          agenix.nixosModules.age
          nix-gaming.nixosModules.pipewireLowLatency
          home-manager.nixosModules.home-manager
          spicetify.nixosModules.default
          modules/programs/spicetify.nix
          modules/imports.nix
          machines/nixos-amd/configuration.nix
          ({ nixpkgs.overlays = overlays; })
        ];
      };
      lenovo = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs overlays; };
        modules = [
          agenix.nixosModules.age
          nix-gaming.nixosModules.pipewireLowLatency
          home-manager.nixosModules.home-manager
          spicetify.nixosModules.default
          modules/programs/spicetify.nix
          modules/imports.nix
          machines/lenovo/configuration.nix
          ({ nixpkgs.overlays = overlays; })
        ];
      };
    };

    packages.${system} = {
      deployIso = (nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [ iso/configuration.nix ];
      }).config.system.build.isoImage;
    };
  };
}
