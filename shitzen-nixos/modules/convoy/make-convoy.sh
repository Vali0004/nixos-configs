#!/usr/bin/env bash
set -euo pipefail

WORKDIR="$(mktemp -d)"
OUTFILE="convoy-panel-offline.tar.gz"

echo "[*] Downloading Convoy Panel latest release..."
curl -L "https://github.com/convoypanel/panel/releases/latest/download/panel.tar.gz" -o "$WORKDIR/panel.tar.gz"

echo "[*] Extracting..."
mkdir "$WORKDIR/panel"
tar -xzf "$WORKDIR/panel.tar.gz" -C "$WORKDIR/panel"

cd "$WORKDIR/panel"

echo "[*] Installing Composer dependencies..."
composer install --no-dev --prefer-dist --optimize-autoloader

echo "[*] Cleaning up unnecessary files..."
rm -rf .git .github tests node_modules resources/js public/js public/css

echo "[*] Archiving for Nix..."
# Ensure deterministic archive
tar --sort=name \
    --owner=0 --group=0 --numeric-owner \
    --mtime="UTC 2020-01-01" \
    -czf "$OLDPWD/$OUTFILE" .

cd "$OLDPWD"

echo "[*] Calculating Nix hash..."
HASH=$(nix hash file "$OUTFILE")

echo
echo "[*] Archive created: $OUTFILE"
echo "[*] sha256: $HASH"
