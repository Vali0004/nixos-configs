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
              toxvpn = super.toxvpn.overrideAttrs (old: {
                patches = [ ./toxvpn-changes.patch ];
              });
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
