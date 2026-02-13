{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-xr = {
      url = "github:nix-community/nixpkgs-xr";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix.url = "github:ryantm/agenix";
    ajax-xdp.url = "github:AjaxVPN/ajax-xdp";
    ajax-deploy.url = "github:AjaxVPN/ajax-deploy";
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
  outputs = inputs@{ self, nixpkgs, nixpkgs-xr, agenix, ajax-xdp, ajax-deploy, home-manager, impermanence, mangowc, nix-gaming, nix-minecraft, nixos-mailserver, spicetify, watchman-pairing-assistant, zfs-utils }:
  let
    system = "x86_64-linux";

    flakeOverlays = [
      (self: super: {
        watchman-pairing-assistant = watchman-pairing-assistant.packages.${system}.default;

        agenix = agenix.outputs.packages.${system}.agenix;
        ajax-xdp = ajax-xdp.packages.${system}.default;
        ajax-deploy = ajax-deploy.packages.${system}.default;
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
        mailserver = nixos-mailserver.${system}.default;
        nixGaming = nix-gaming.outputs.packages.${system};
        spicetifyThemes = spicetify.outputs.legacyPackages.${system}.themes;
        spicetifyExtensions = spicetify.outputs.legacyPackages.${system}.extensions;
        zfs-fragmentation = zfs-utils.packages.${system}.zfs-fragmentation;
        txg-watcher = zfs-utils.packages.${system}.txg-watcher;
      })
    ];

    overlays = [
      nix-minecraft.overlay
      (import overlays/customPackages.nix)
      (import overlays/existingPackages.nix)
      (import overlays/server.nix)
    ] ++ flakeOverlays;

    coreImports = [
      agenix.nixosModules.age
      modules/zfs/zfs-patch.nix
      ./core.nix
    ];

    pkgs = import nixpkgs { inherit system overlays; };
  in {
    colmena = {
      meta = {
        specialArgs = {
          lib = (import overlays/libOverlay.nix {
            lib = pkgs.lib;
            inherit pkgs;
          }).lib;
        };
        nixpkgs = pkgs;
      };
      router-vps = {
        deployment = {
          targetHost = "74.208.44.130";
          targetUser = "root";
          targetPort = 1594;
        };
        imports = coreImports ++ [
          machines/router-vps/configuration.nix
        ];
      };
      nixos-shitclient = {
        deployment = {
          targetHost = "10.0.0.2";
          targetUser = "root";
          targetPort = 22;
        };
        imports = coreImports ++ [
          machines/nixos-shitclient/configuration.nix
        ];
      };
      nixos-jaguar = {
        deployment = {
          targetHost = "10.0.0.193";
          targetUser = "root";
          targetPort = 22;
        };
        imports = coreImports ++ [
          modules/zfs/zfs-patch.nix
          machines/nixos-jaguar/configuration.nix
        ];
      };
      shitzen-nixos = {
        deployment = {
          targetHost = "10.0.0.4";
          targetUser = "root";
          targetPort = 22;
        };
        imports = coreImports ++ [
          nix-minecraft.nixosModules.minecraft-servers
          nixos-mailserver.nixosModule
          machines/shitzen-nixos/configuration.nix
        ];
      };
      nixos-hass = {
        deployment = {
          targetHost = "10.0.0.3";
          targetUser = "root";
          targetPort = 22;
        };
        imports = coreImports ++ [
          machines/nixos-hass/configuration.nix
        ];
      };
      nixos-router = {
        deployment = {
          targetHost = "10.0.0.1";
          targetUser = "root";
          targetPort = 22;
        };
        imports = coreImports ++ [
          machines/nixos-router/configuration.nix
        ];
      };
    };

    nixosConfigurations = {
      # Building a flake system:
      # nix build .#nixosConfigurations.<name>.config.system.build.toplevel
      nixos-amd = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs overlays; };
        modules = [
          agenix.nixosModules.age
          nix-gaming.nixosModules.pipewireLowLatency
          nixpkgs-xr.nixosModules.nixpkgs-xr
          home-manager.nixosModules.home-manager
          spicetify.nixosModules.default
          modules/programs/spicetify.nix
          modules/programs/steam.nix
          modules/imports.nix
          machines/nixos-amd/configuration.nix
          overlays/module.nix
          ({ nixpkgs.overlays = flakeOverlays; })
        ];
      };
      lenovo = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs overlays; };
        modules = [
          agenix.nixosModules.age
          nix-gaming.nixosModules.pipewireLowLatency
          nixpkgs-xr.nixosModules.nixpkgs-xr
          home-manager.nixosModules.home-manager
          spicetify.nixosModules.default
          modules/programs/spicetify.nix
          modules/programs/steam.nix
          modules/services/openssh.nix
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