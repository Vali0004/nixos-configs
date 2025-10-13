{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    agenix.url = "github:ryantm/agenix";
    ajax-xdp.url = "/home/vali/development/ajax-xdp";
    impermanence.url = "github:nix-community/impermanence";
    nix-gaming.url = "github:fufexan/nix-gaming";
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
    nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
    openhmd.url = "github:Vali0004/OpenHMD/c56529c22618325dfc31e7c44f17e804cb7e7edf";
    spicetify.url = "github:Gerg-L/spicetify-nix";
    zfs-utils = {
      url = "github:cleverca22/zfs-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, agenix, ajax-xdp, impermanence, nix-gaming, nix-minecraft, nixos-mailserver, openhmd, spicetify, zfs-utils }:
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
        agenix = agenix.outputs.packages.x86_64-linux.agenix;
        ajax-xdp = ajax-xdp.packages.x86_64-linux.default;
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
        nixGaming = nix-gaming.outputs.packages.x86_64-linux;
        openhmd = openhmd.outputs.packages.x86_64-linux.openhmd;
        spicetifyThemes = spicetify.outputs.legacyPackages.x86_64-linux.themes;
        spicetifyExtensions = spicetify.outputs.legacyPackages.x86_64-linux.extensions;
        zfs-fragmentation = zfs-utils.packages.x86_64-linux.zfs-fragmentation;
      })
      # Existing pkgs
      (self: super: {
        dmenu = super.dmenu.overrideAttrs (old: {
          buildInputs = (old.buildInputs or []) ++ [ self.libspng ];
          src = /home/vali/development/dmenu;
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
            rev = "cd7c67e75dd782c46c38dee38722ea64abe6d463";
            hash = "sha256-Ij52wdZznFQSaCA2UoqZxLVn2BkBLqtoNS1EKEcQphg=";
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
      shitzen-nixos = {
        deployment = {
          targetHost = "10.0.0.244";
          targetUser = "root";
          targetPort = 22;
        };
        imports = coreImports ++ [
          nix-minecraft.nixosModules.minecraft-servers
          nixos-mailserver.nixosModule
          machines/shitzen-nixos/configuration.nix
        ];
      };
    };

    nixosConfigurations = {
      nixos-amd = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          agenix.nixosModules.age
          nix-gaming.nixosModules.pipewireLowLatency
          spicetify.nixosModules.default
          modules/imports.nix
          machines/nixos-amd/configuration.nix
          ({ ... }: {
            nixpkgs.overlays = overlays;
          })
        ];
      };
      lenovo = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          agenix.nixosModules.age
          nix-gaming.nixosModules.pipewireLowLatency
          spicetify.nixosModules.default
          modules/imports.nix
          machines/lenovo/configuration.nix
          ({ ... }: {
            nixpkgs.overlays = overlays;
          })
        ];
      };
    };

    packages.${system}.deployIso = (nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [ iso/configuration.nix ];
    }).config.system.build.isoImage;
  };
}
