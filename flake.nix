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
