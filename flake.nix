{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
  };
  outputs = { nixpkgs, nix-minecraft, self }:
  {
    colmena = {
      meta = {
        nixpkgs = import nixpkgs {
          system = "x86_64-linux";
          overlays = [
            nix-minecraft.overlay 
            (self: super: {
              toxvpn = (builtins.getFlake "github:cleverca22/toxvpn/1830f9b8c12b4c5ef36b1f60f7e600cd1ecf4ccf").packages.x86_64-linux.default;
            })
            (self: super: {
              forgeServers = {
                forge-1_7_10-10_13_4 = self.callPackage ./pkgs/nix-minecraft/forge/forge.nix { version = "1.7.10-10.13.4.1614-1.7.10"; };
                forge-1_16_5-36_2_39 = self.callPackage ./pkgs/nix-minecraft/forge/forge.nix { version = "1.16.5-36.2.39"; };
                forge-1_16_5-36_2_42 = self.callPackage ./pkgs/nix-minecraft/forge/forge.nix { version = "1.16.5-36.2.42"; };
                forge-1_20_1-47_3_0 = self.callPackage ./pkgs/nix-minecraft/forge/forge.nix { version = "1.20.1-47.3.0"; };
              };
            })
          ];
        };
      };
      router = {
        deployment.targetHost = "31.59.128.34";
        deployment.targetUser = "root";
        imports = [
          ./core.nix
          ./router/configuration.nix
        ];
      };
      shitzen-nixos = {
        deployment.targetHost = "10.0.0.244";
        deployment.targetUser = "root";
        imports = [
          ./core.nix
          nix-minecraft.nixosModules.minecraft-servers
          ./shitzen-nixos/configuration.nix
        ];
      };
    };
  };
}
