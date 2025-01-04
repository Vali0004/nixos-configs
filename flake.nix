{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  outputs = { nixpkgs, self }:
  {
    colmena = {
      meta = {
        nixpkgs = import nixpkgs {
          system = "x86_64-linux";
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
          ./shitzen-nixos/configuration.nix
        ];
      };
    };
  };
}
