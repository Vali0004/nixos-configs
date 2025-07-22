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
    echo "Run:"
    echo "SETUP_DB=true \\"
    echo "DB_PASSWORD=my-secret-db-pass \\"
    echo "CREATE_ADMIN=true \\"
    echo "DEFAULT_ADMIN_EMAIL=admin@example.com \\"
    echo "DEFAULT_ADMIN_PASSWORD=s3cret123 \\"
    echo "./make-convoy.sh"
    echo ""
  '';
}
