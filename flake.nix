{
  inputs = {
    agenix.url = "github:ryantm/agenix";
    impermanence.url = "github:nix-community/impermanence";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
    nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
    toxvpn = {
      url = "github:cleverca22/toxvpn/403586be0181a0b20dfc0802580f7f919aaa83de";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zfs-utils = {
      url = "github:cleverca22/zfs-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, agenix, impermanence, nix-minecraft, nixos-mailserver, toxvpn, zfs-utils }:
  let
    system = "x86_64-linux";
    coreImports = [
      agenix.nixosModules.age
      ./core.nix
    ];
    pkgs = import nixpkgs {
      inherit system;
      overlays = [
        (self: super: {
          agenix = agenix.packages.x86_64-linux.default;
          forgeServers = {
            forge-1_7_10-10_13_4 = self.callPackage ./pkgs/nix-minecraft/forge { version = "1.7.10-10.13.4.16"; };
            forge-1_16_5-36_2_26 = self.callPackage ./pkgs/nix-minecraft/forge { version = "1.16.5-36.2.26"; };
            forge-1_16_5-36_2_39 = self.callPackage ./pkgs/nix-minecraft/forge { version = "1.16.5-36.2.39"; };
            forge-1_16_5-36_2_42 = self.callPackage ./pkgs/nix-minecraft/forge { version = "1.16.5-36.2.42"; };
            forge-1_18_2-40_3_0 = self.callPackage ./pkgs/nix-minecraft/forge { version = "1.18.2-40.3.0"; };
            forge-1_20_1-47_2_17 = self.callPackage ./pkgs/nix-minecraft/forge { version = "1.20.1-47.2.17"; };
            forge-1_20_1-47_3_0 = self.callPackage ./pkgs/nix-minecraft/forge { version = "1.20.1-47.3.0"; };
            forge-1_20_1-47_4_0 = self.callPackage ./pkgs/nix-minecraft/forge { version = "1.20.1-47.4.0"; };
          };
          mailserver = nixos-mailserver.x86_64-linux.default;
          toxvpn = toxvpn.packages.x86_64-linux.default;
          zfs-fragmentation = zfs-utils.packages.x86_64-linux.zfs-fragmentation;
        })
        nix-minecraft.overlay
      ];
    };
  in {
    colmena = {
      meta.nixpkgs = pkgs;
      router-vps = {
        deployment.targetHost = "74.208.44.130";
        deployment.targetUser = "root";
        imports = coreImports ++ [
          ./router-vps/configuration.nix
        ];
      };
      shitzen-nixos = {
        deployment.targetHost = "10.0.0.244";
        deployment.targetUser = "root";
        imports = coreImports ++ [
          nix-minecraft.nixosModules.minecraft-servers
          nixos-mailserver.nixosModule
          ./shitzen-nixos/configuration.nix
        ];
      };
      testvm-nixos = {
        deployment.targetHost = "192.168.122.242";
        deployment.targetUser = "root";
        imports = coreImports ++ [
          impermanence.nixosModules.impermanence
          ./testvm-nixos/configuration.nix
        ];
      };
    };

    packages.${system}.isoVali = (nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [ ./iso/configuration.nix ];
    }).config.system.build.isoImage;
  };
}
