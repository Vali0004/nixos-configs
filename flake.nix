{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
    pterodactyl-wings-nix.url = "github:BadCoder-Network/pterodactyl-wings-nix";
    nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
    agenix.url = "github:ryantm/agenix";
    proxmox-nixos.url = "github:SaumonNet/proxmox-nixos";
  };
  outputs = { nixpkgs, agenix, nix-minecraft, nixos-mailserver, pterodactyl-wings-nix, proxmox-nixos, self }:
  {
    colmena = {
      meta = {
        nixpkgs = import nixpkgs {
          system = "x86_64-linux";
          overlays = [
            proxmox-nixos.overlays.x86_64-linux
            (self: super: {
              agenix = agenix.packages.x86_64-linux.default;
            })
            nix-minecraft.overlay
            (self: super: {
              toxvpn = (builtins.getFlake "github:cleverca22/toxvpn/1830f9b8c12b4c5ef36b1f60f7e600cd1ecf4ccf").packages.x86_64-linux.default;
            })
            (self: super: {
              mailserver = nixos-mailserver.x86_64-linux.default;
            })
            (self: super: {
              wings = pterodactyl-wings-nix.packages.x86_64-linux.pterodactyl-wings;
            })
            (self: super: {
              forgeServers = {
                forge-1_7_10-10_13_4 = self.callPackage ./pkgs/nix-minecraft/forge/forge.nix { version = "1.7.10-10.13.4.1614-1.7.10"; };
                forge-1_16_5-36_2_26 = self.callPackage ./pkgs/nix-minecraft/forge/forge.nix { version = "1.16.5-36.2.26"; };
                forge-1_16_5-36_2_39 = self.callPackage ./pkgs/nix-minecraft/forge/forge.nix { version = "1.16.5-36.2.39"; };
                forge-1_16_5-36_2_42 = self.callPackage ./pkgs/nix-minecraft/forge/forge.nix { version = "1.16.5-36.2.42"; };
                forge-1_18_2-40_3_0 = self.callPackage ./pkgs/nix-minecraft/forge/forge.nix { version = "1.18.2-40.3.0"; };
                forge-1_20_1-47_2_17 = self.callPackage ./pkgs/nix-minecraft/forge/forge.nix { version = "1.20.1-47.2.17"; };
                forge-1_20_1-47_3_0 = self.callPackage ./pkgs/nix-minecraft/forge/forge.nix { version = "1.20.1-47.3.0"; };
                forge-1_20_1-47_4_0 = self.callPackage ./pkgs/nix-minecraft/forge/forge.nix { version = "1.20.1-47.4.0"; };
              };
            })
          ];
        };
      };
      router = {
        deployment.targetHost = "74.208.44.130";
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
          agenix.nixosModules.age
          ./core.nix
          nix-minecraft.nixosModules.minecraft-servers
          pterodactyl-wings-nix.nixosModules.pterodactyl-wings
          nixos-mailserver.nixosModule
          proxmox-nixos.nixosModules.proxmox-ve
          ./shitzen-nixos/configuration.nix
        ];
      };
    };
  };
}
