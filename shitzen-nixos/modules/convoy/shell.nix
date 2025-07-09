{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  name = "make-convoy-offline-env";

  buildInputs = with pkgs; [
    php82
    php82Packages.composer
    curl
    gnutar
    gzip
    findutils
    nix
    coreutils
  ];

  shellHook = ''
    echo ""
    echo "Run: ./make-convoy.sh"
    echo ""
  '';
}
