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

# Optional DB setup
if [[ "${SETUP_DB:-false}" == "true" ]]; then
  echo "[*] Creating MySQL database and user..."
  mysql -u convoy -h "${DB_HOST:-127.0.0.1}" -p"${DB_PASSWORD:-changeme}" <<EOF
CREATE DATABASE IF NOT EXISTS convoy;
CREATE USER IF NOT EXISTS 'convoy'@'%' IDENTIFIED BY '${DB_PASSWORD:-changeme}';
GRANT ALL PRIVILEGES ON convoy.* TO 'convoy'@'%';
FLUSH PRIVILEGES;
EOF
fi

# Optional admin user creation
if [[ "${CREATE_ADMIN:-false}" == "true" ]]; then
  echo "[*] Creating default admin user..."
  if [[ -z "${DEFAULT_ADMIN_EMAIL:-}" || -z "${DEFAULT_ADMIN_PASSWORD:-}" ]]; then
    echo "ERROR: DEFAULT_ADMIN_EMAIL and DEFAULT_ADMIN_PASSWORD must be set"
    exit 1
  fi
  php artisan c:user:make --email="$DEFAULT_ADMIN_EMAIL" --password="$DEFAULT_ADMIN_PASSWORD"
fi

echo "[*] Archiving..."
# Ensure deterministic archive
tar --sort=name \
    --owner=0 --group=0 --numeric-owner \
    --mtime="UTC 2020-01-01" \
    -czf "$OLDPWD/$OUTFILE" .

cd "$OLDPWD"

echo "[*] Calculating hash..."
HASH=$(nix hash file "$OUTFILE")

echo
echo "[*] Archive created: $OUTFILE"
echo "[*] sha256: $HASH"
