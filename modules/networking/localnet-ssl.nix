{ lib
, pkgs
, config
, ... }:

let
  cfg = config.services.localnetSSL;

  nginxUser = config.services.nginx.user or "nginx";
  nginxGroup = config.services.nginx.group or "nginx";

  baseDir = cfg.baseDir;
  caDir = "${baseDir}/ca/root";
  issuedDir = "${baseDir}/issued";
  chainsDir = "${baseDir}/chains";
  keysDir = "${baseDir}/keys";

  mkScript = pkgs.writeShellScript "localnet-ssl-ensure" ''
    set -euo pipefail

    BASE="${baseDir}"
    CA_DIR="${caDir}"
    ISSUED="${issuedDir}"
    CHAINS="${chainsDir}"
    KEYS="${keysDir}"

    mkdir -p "$CA_DIR" "$ISSUED" "$CHAINS" "$KEYS"

    # Ensure CA exists (create if missing)
    if [ ! -f "$CA_DIR/localnet-rootCA.crt" ] || [ ! -f "$CA_DIR/localnet-rootCA.key" ]; then
      echo "localnetSSL: generating local CA in $CA_DIR"
      ${pkgs.openssl}/bin/openssl genrsa -out "$CA_DIR/localnet-rootCA.key" 4096
      ${pkgs.openssl}/bin/openssl req -x509 -new -nodes \
        -key "$CA_DIR/localnet-rootCA.key" \
        -sha256 -days ${toString cfg.caDays} \
        -subj ${lib.escapeShellArg cfg.caSubject} \
        -out "$CA_DIR/localnet-rootCA.crt"
      chmod 600 "$CA_DIR/localnet-rootCA.key"
    fi

    # Function: should renew? (1 = yes, 0 = no)
    should_renew() {
      local cert="$1"
      # If cert doesn't exist, renew
      if [ ! -f "$cert" ]; then return 0; fi
      # If cert expires within renewBeforeSeconds, renew
      if ! ${pkgs.openssl}/bin/openssl x509 -in "$cert" -noout -checkend ${toString cfg.renewBeforeSeconds} >/dev/null; then
        return 0
      fi
      return 1
    }

    changed=0

    ${lib.concatStringsSep "\n" (map (host: ''
      host=${lib.escapeShellArg host}

      leaf_dir="$ISSUED/$host"
      leaf_cert="$leaf_dir/cert.pem"
      leaf_key="$leaf_dir/key.pem"

      fullchain="$CHAINS/$host.pem"
      keylink="$KEYS/${lib.escapeShellArg (builtins.replaceStrings [".localnet"] [""] host)}.key"

      # We also support key name == full host (more explicit):
      keylink2="$KEYS/$host.key"

      if should_renew "$leaf_cert"; then
        echo "localnetSSL: issuing/renewing cert for $host"
        # minica always writes into a directory named after the first domain; run it in ISSUED
        ( cd "$ISSUED" && ${pkgs.minica}/bin/minica \
          -ca-cert "$CA_DIR/localnet-rootCA.crt" \
          -ca-key  "$CA_DIR/localnet-rootCA.key" \
          -domains "$host" )
        changed=1
      fi

      # Build fullchain atomically
      tmp="$(mktemp)"
      cat "$leaf_cert" "$CA_DIR/localnet-rootCA.crt" > "$tmp"
      if [ ! -f "$fullchain" ] || ! ${pkgs.coreutils}/bin/cmp -s "$tmp" "$fullchain"; then
        ${pkgs.coreutils}/bin/install -m 0644 "$tmp" "$fullchain"
        changed=1
      fi
      rm -f "$tmp"

      # Key symlinks
      mkdir -p "$KEYS"
      ln -snf "../issued/$host/key.pem" "$keylink2"

      # Optional convenience symlink: <name>.key (strip .localnet)
      name="''${host%.localnet}"
      ln -snf "../issued/$host/key.pem" "$KEYS/$name.key"

    '') cfg.hosts)}

    # Ownership (nginx-readable)
    chown -R ${lib.escapeShellArg nginxUser}:${lib.escapeShellArg nginxGroup} "$BASE"
    chmod 600 "$CA_DIR/localnet-rootCA.key" || true

    # Reload nginx if we changed anything and nginx is running
    if [ "$changed" -eq 1 ]; then
      echo "localnetSSL: changes detected; reloading nginx"
      if ${pkgs.systemd}/bin/systemctl -q is-active nginx; then
        ${pkgs.systemd}/bin/systemctl reload nginx
      fi
    fi
  '';

in
{
  options.services.localnetSSL = {
    enable = lib.mkEnableOption "local CA + minica certificates for nginx vhosts (localnetSSL)";

    baseDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/localnet";
      description = "Base directory for CA, issued certs, chains, and keys.";
    };

    caSubject = lib.mkOption {
      type = lib.types.str;
      default = "/C=US/O=localnet/OU=homelab/CN=localnet Root CA";
      description = "X.509 subject for the local root CA.";
    };

    caDays = lib.mkOption {
      type = lib.types.int;
      default = 3650;
      description = "CA validity in days.";
    };

    # Renew leaf certs when they have less than this much time left
    renewBeforeSeconds = lib.mkOption {
      type = lib.types.int;
      default = 60 * 60 * 24 * 30; # 30 days
      description = "Renew certificates if expiring within this many seconds.";
    };

    enableTimer = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Run a periodic timer to renew certs proactively.";
    };

    timerOnCalendar = lib.mkOption {
      type = lib.types.str;
      default = "daily";
      description = "systemd OnCalendar value for renewal checks.";
    };

    hosts = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "List of nginx vhost names (FQDNs) to manage with localnetSSL.";
    };
  };

  # Extend nginx vhost schema with localnetSSL option
  config = lib.mkIf cfg.enable {
    services.nginx.virtualHosts = lib.genAttrs cfg.hosts (name: {
      addSSL = lib.mkDefault true;
      enableACME = lib.mkDefault false;
      sslCertificate = lib.mkDefault "${chainsDir}/${name}.pem";
      sslCertificateKey = lib.mkDefault "${keysDir}/${name}.key";
    });

    systemd.services.localnet-ssl-ensure = {
      description = "Ensure localnet SSL certs exist for nginx localnetSSL vhosts";
      requiredBy = [ "nginx.service" ];
      before = [ "nginx.service" ];
      partOf = [ "nginx.service" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = mkScript;
      };
    };

    systemd.timers.localnet-ssl-ensure = lib.mkIf cfg.enableTimer {
      description = "Renew localnet SSL certs periodically";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.timerOnCalendar;
        Persistent = true;
        RandomizedDelaySec = 3600;
      };
    };
  };
}