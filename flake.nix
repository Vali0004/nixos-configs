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
        imports = [ ./router/configuration.nix ];
      };
    };
  };
}
