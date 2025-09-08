{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
    nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
    agenix.url = "github:ryantm/agenix";
  };
  outputs = { nixpkgs, agenix, nix-minecraft, nixos-mailserver, self }:
  {
    colmena = {
      meta = {
        nixpkgs = import nixpkgs {
          system = "x86_64-linux";
          overlays = [
            (self: super: {
              agenix = agenix.packages.x86_64-linux.default;
            })
            nix-minecraft.overlay
            (self: super: {
              toxvpn = (builtins.getFlake "github:cleverca22/toxvpn/403586be0181a0b20dfc0802580f7f919aaa83de").packages.x86_64-linux.default;
            })
            (self: super: {
              mailserver = nixos-mailserver.x86_64-linux.default;
            })
            (self: super: {
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
            })
          ];
        };
      };
      router = {
        deployment.targetHost = "74.208.44.130";
        deployment.targetUser = "root";
        imports = [
          agenix.nixosModules.age
          ./core.nix
          ./router/configuration.nix
        ];
      };
      shitzen-nixos = {
        deployment.targetHost = "10.0.0.244";
        deployment.targetUser = "root";
        imports = [
          agenix.nixosModules.age
          ./core.nix
          nix-minecraft.nixosModules.minecraft-servers
          nixos-mailserver.nixosModule
          ./shitzen-nixos/configuration.nix
        ];
      };
    };
  };
}
