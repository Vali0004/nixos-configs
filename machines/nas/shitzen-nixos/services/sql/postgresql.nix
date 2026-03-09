{ config
, pkgs
, ... }:

{
  services.postgresql = {
    enable = true;
    enableJIT = true;
    # Needed for Sogo
    enableTCPIP = true;
    authentication = ''
      # Allow SOGo to authenticate via password in the netns
      host  sogo  sogo  192.168.100.0/24  scram-sha-256
      host  sogo  sogo  fd00:100::/64     scram-sha-256
    '';
    ensureDatabases = [
      config.services.gitea.database.user
      "nextcloud"
      "sogo"
    ];
    ensureUsers = [
      {
        name = config.services.gitea.database.user;
        ensureDBOwnership = true;
        ensureClauses = {
          createdb = true;
        };
      }
      {
        name = "nextcloud";
        ensureClauses = {
          createdb = true;
        };
      }
      {
        name = "sogo";
        ensureDBOwnership = true;
        ensureClauses = {
          createdb = true;
        };
      }
    ];
    package = pkgs.postgresql_16;
    settings = {
      # Some services are in a netns
      listen_addresses = "*";
      port = 5432;
    };
  };

  systemd.services."postgresql-ensure-dbs" = {
    description = "Initialize PostgreSQL users";
    after = [ "postgresql.service" ];
    requires = [ "postgresql.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      User = "postgres";
      StandardOutput = "journal";
      StandardError = "journal";
    };

    script = ''
      set -e

      # Fix SOGo ownership and privileges
      ${config.services.postgresql.package}/bin/psql <<EOF
ALTER DATABASE sogo OWNER TO sogo;

GRANT ALL PRIVILEGES ON DATABASE sogo TO sogo;

-- Grant access to existing tables
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO sogo;

-- Grant access to sequences (future proofs)
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO sogo;

-- Ensure future tables inherit privileges
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO sogo;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON SEQUENCES TO sogo;
EOF
      # Read passwords from age secrets at runtime
      GITEA_PW="$(cat ${config.age.secrets.git-kursu-dev-db.path})"

      # Set DB user passwords
      ${config.services.postgresql.package}/bin/psql <<EOF
ALTER USER ${config.services.gitea.database.user} WITH PASSWORD '$GITEA_PW';
EOF
    '';
  };
}