{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/c06b4ae3d6599a672a6210b7021d699c351eebda";
    agenix.url = "github:ryantm/agenix";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hytale-launcher.url = "github:JPyke3/hytale-launcher-nix";
    nix-gaming.url = "github:fufexan/nix-gaming";
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
    nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
    pterodactyl-wings-nix.url = "github:BadCoder-Network/pterodactyl-wings-nix";
    skylanders-nfc-reader.url = "github:Vali0004/skylanders-nfc-reader";
    spicetify.url = "github:Gerg-L/spicetify-nix";
    zfs-utils = {
      url = "github:cleverca22/zfs-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self
    , nixpkgs
    , nixpkgs-stable
    , agenix
    , home-manager
    , hytale-launcher
    , nix-gaming
    , nix-minecraft
    , nixos-mailserver
    , pterodactyl-wings-nix
    , skylanders-nfc-reader
    , spicetify
    , zfs-utils
  }: let
    system = "x86_64-linux";

    flakeOverlays = [
      (self: super: {
        agenix = agenix.outputs.packages.${system}.agenix;
        hytale-launcher = hytale-launcher.outputs.packages.${system}.default;
        mailserver = nixos-mailserver.${system}.default;
        nixGaming = nix-gaming.outputs.packages.${system};
        skylanders-nfc-reader = skylanders-nfc-reader.packages.${system}.default;
        spicetifyThemes = spicetify.outputs.legacyPackages.${system}.themes;
        spicetifyExtensions = spicetify.outputs.legacyPackages.${system}.extensions;
        zfs-fragmentation = zfs-utils.packages.${system}.zfs-fragmentation;
        txg-watcher = zfs-utils.packages.${system}.txg-watcher;
        wings = pterodactyl-wings-nix.packages.x86_64-linux.pterodactyl-wings;
      })
    ];

    overlays = [
      nix-minecraft.overlay
      (import overlays/customPackages.nix)
      (import overlays/existingPackages.nix)
    ] ++ flakeOverlays;

    pkgs = import nixpkgs { inherit system overlays; };

    pkgsStable = import nixpkgs-stable { inherit system overlays; };

    specialArgs = {
      # Cursed trick to get a proper lib override,
      # used for mkNamespace, mkPrometheusJob, and mkProxy
      lib = (import overlays/libOverlay.nix {
        lib = pkgs.lib;
        inherit pkgs;
      }).lib;
      inherit inputs overlays;
    };
  in {
    colmena = {
      defaults = {
        imports = [
          agenix.nixosModules.age
          modules/nix/remote-deploy.nix
          modules/zfs/zfs-patch.nix
          ./core.nix
        ];
      };
      meta = {
        inherit specialArgs;
        nixpkgs = pkgs;
        nodeNixpkgs = {
          nixos-router = pkgsStable;
        };
      };
      nixos-router = {
        deployment.targetHost = "10.0.0.1";
        imports = [
          machines/house/nixos-router/configuration.nix
        ];
      };
      home-assistant = {
        deployment.targetHost = "10.0.0.2";
        imports = [
          machines/house/02-home-assistant-localnet/configuration.nix
        ];
      };
      unused-now = {
        deployment.targetHost = "10.0.0.3";
        imports = [
          machines/house/03-unused-now/configuration.nix
        ];
      };
      shitzen-nixos = {
        deployment.targetHost = "10.0.0.4";
        imports = [
          nix-minecraft.nixosModules.minecraft-servers
          nixos-mailserver.nixosModule
          pterodactyl-wings-nix.nixosModules.pterodactyl-wings
          modules/networking/hosts.nix
          machines/nas/shitzen-nixos/configuration.nix
          modules/pterodactyl.nix
        ];
      };
      nas-wg-exitnode = {
        deployment = {
          targetHost = "74.208.44.130";
          targetPort = 1594;
        };
        imports = [
          machines/cloud/01-nas-wg-exitnode/configuration.nix
        ];
      };
    };

    nixosConfigurations = {
      # Building a flake system:
      # nix build .#nixosConfigurations.<name>.config.system.build.toplevel
      nixos-amd = nixpkgs.lib.nixosSystem {
        inherit system specialArgs;
        modules = [
          ({ nixpkgs.overlays = flakeOverlays; })
          agenix.nixosModules.age
          nix-gaming.nixosModules.pipewireLowLatency
          home-manager.nixosModules.home-manager
          spicetify.nixosModules.default
          modules/networking/hosts.nix
          modules/programs/spicetify.nix
          modules/programs/steam.nix
          modules/imports.nix
          overlays/module.nix
          machines/personal/nixos-amd/configuration.nix
        ];
      };
      lenovo = nixpkgs.lib.nixosSystem {
        inherit system specialArgs;
        modules = [
          ({ nixpkgs.overlays = overlays; })
          agenix.nixosModules.age
          nix-gaming.nixosModules.pipewireLowLatency
          home-manager.nixosModules.home-manager
          spicetify.nixosModules.default
          overlays/module.nix
          modules/networking/hosts.nix
          modules/programs/spicetify.nix
          modules/programs/steam.nix
          modules/services/openssh.nix
          modules/imports.nix
          machines/personal/lenovo/configuration.nix
        ];
      };
      shitzen-nixos = nixpkgs.lib.nixosSystem {
        inherit system specialArgs;
        modules = [
          ({ nixpkgs.overlays = overlays; })
          agenix.nixosModules.age
          nix-minecraft.nixosModules.minecraft-servers
          nixos-mailserver.nixosModule
          modules/zfs/zfs-patch.nix
          ./core.nix
          modules/networking/hosts.nix
          machines/nas/shitzen-nixos/configuration.nix
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