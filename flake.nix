{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-xr = {
      url = "github:nix-community/nixpkgs-xr";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix.url = "github:ryantm/agenix";
    #ajax-xdp.url = "github:AjaxVPN/ajax-xdp";
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

    flakeOverlays = [
      (self: super: {
        watchman-pairing-assistant = watchman-pairing-assistant.packages.x86_64-linux.default;

        agenix = agenix.outputs.packages.x86_64-linux.agenix;
        ajax-xdp = ajax-xdp.packages.x86_64-linux.default;
        forgeServers = {
          forge-1_7_10-10_13_4 = self.callPackage overlays/pkgs/nix-minecraft/forge { version = "1.7.10-10.13.4.16"; };
          forge-1_16_5-36_2_26 = self.callPackage overlays/pkgs/nix-minecraft/forge { version = "1.16.5-36.2.26"; };
          forge-1_16_5-36_2_39 = self.callPackage overlays/pkgs/nix-minecraft/forge { version = "1.16.5-36.2.39"; };
          forge-1_16_5-36_2_42 = self.callPackage overlays/pkgs/nix-minecraft/forge { version = "1.16.5-36.2.42"; };
          forge-1_18_2-40_3_0  = self.callPackage overlays/pkgs/nix-minecraft/forge { version = "1.18.2-40.3.0";  };
          forge-1_20_1-47_2_17 = self.callPackage overlays/pkgs/nix-minecraft/forge { version = "1.20.1-47.2.17"; };
          forge-1_20_1-47_3_0  = self.callPackage overlays/pkgs/nix-minecraft/forge { version = "1.20.1-47.3.0";  };
          forge-1_20_1-47_4_0  = self.callPackage overlays/pkgs/nix-minecraft/forge { version = "1.20.1-47.4.0";  };
        };
        mailserver = nixos-mailserver.x86_64-linux.default;
        nixGaming = nix-gaming.outputs.packages.x86_64-linux;
        skylanders-nfc-reader = skylanders-nfc-reader.outputs.packages.x86_64-linux.default;
        spicetifyThemes = spicetify.outputs.legacyPackages.x86_64-linux.themes;
        spicetifyExtensions = spicetify.outputs.legacyPackages.x86_64-linux.extensions;
        zfs-fragmentation = zfs-utils.packages.x86_64-linux.zfs-fragmentation;
      })
    ];
    overlays = [
      nix-minecraft.overlay
      (import overlays/existingPackages.nix)
      (import overlays/server.nix)
    ] ++ flakeOverlays;

    coreImports = [
      agenix.nixosModules.age
      ./core.nix
    ];

    pkgs = import nixpkgs { inherit system overlays; };

    specialArgs = {
      lib = (import overlays/libOverlay.nix {
        lib = pkgs.lib;
        inherit pkgs;
      }).lib;
    };
  in {
    colmena = {
      meta = {
        specialArgs = specialArgs;
        nixpkgs = pkgs;
      };
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
          targetHost = "10.0.0.6";
          targetUser = "root";
          targetPort = 22;
        };
        imports = coreImports ++ [
          nix-minecraft.nixosModules.minecraft-servers
          nixos-mailserver.nixosModule
          machines/shitzen-nixos/configuration.nix
        ];
      };
      nixos-router = {
        deployment = {
          targetHost = "192.168.0.200";
          targetUser = "root";
          targetPort = 22;
        };
        imports = coreImports ++ [
          machines/nixos-router/configuration.nix
        ];
      };
      ajaxvpn-nixos = {
        deployment = {
          targetHost = "45.139.50.22";
          targetUser = "root";
          targetPort = 22;
        };
        imports = coreImports ++ [
          machines/ajaxvpn-nixos/configuration.nix
        ];
      };
    };

    nixosConfigurations = {
      nixos-amd = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          lib = specialArgs.lib;
          inherit inputs overlays;
        };
        modules = [
          agenix.nixosModules.age
          nix-gaming.nixosModules.pipewireLowLatency
          nixpkgs-xr.nixosModules.nixpkgs-xr
          home-manager.nixosModules.home-manager
          spicetify.nixosModules.default
          modules/programs/spicetify.nix
          modules/imports.nix
          machines/nixos-amd/configuration.nix
          overlays/module.nix
          ({ nixpkgs.overlays = flakeOverlays; })
        ];
      };
      lenovo = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          lib = specialArgs.lib;
          inherit inputs overlays;
        };
        modules = [
          agenix.nixosModules.age
          nix-gaming.nixosModules.pipewireLowLatency
          home-manager.nixosModules.home-manager
          spicetify.nixosModules.default
          modules/programs/spicetify.nix
          modules/imports.nix
          machines/lenovo/configuration.nix
          overlays/module.nix
          ({ nixpkgs.overlays = flakeOverlays; })
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
