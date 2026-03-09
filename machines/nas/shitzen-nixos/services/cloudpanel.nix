{ config
, lib
, pkgs
, ... }:

let
  cloudpanelDeb = pkgs.fetchurl {
    url = "https://d17k9fuiwb52nc.cloudfront.net/pool/main/c/cloudpanel/cloudpanel_2.5.3-1+clp-bookworm_all.deb";
    sha256 = "sha256-PwPNCe1LQlNmqQ27u+AG2/jmeEevgxPgTi/j0IKK6I0=";
  };

  tz = "America/Detroit";

  root = "/var/lib/cloudpanel/root";

  stateRoot = "/var/lib/cloudpanel/state";

  extracted = pkgs.stdenvNoCC.mkDerivation {
    pname = "cloudpanel-extracted";
    version = "2.5.3";
    nativeBuildInputs = [ pkgs.dpkg ];
    unpackPhase = "true";
    installPhase = ''
      mkdir -p $out
      dpkg-deb -x ${cloudpanelDeb} $out
    '';
  };

  app = "${extracted}/tmp/cloudpanel/data/cloudpanel/files";

  public = "${app}/public";

  clpPhp = pkgs.php83.buildEnv {
    extensions = ({ enabled, all }: enabled ++ (with all; [
      bcmath curl fileinfo filter gd gmp intl mbstring openssl
      pdo pdo_mysql session zip
      redis memcached
    ]));
  };
  phpVer = "8.3";
  phpEtc = "${clpPhp}/etc/php";
  fpmEtc = "/etc/php/${phpVer}/fpm";

  ioncube = pkgs.php83Extensions.ioncube-loader;

  runtimeLibs = with pkgs; [
    stdenv.cc.cc.lib
    glibc
    zlib
    openssl
    curl
    libcap
    libuuid
  ];

  clpAgent = pkgs.stdenvNoCC.mkDerivation {
    pname = "clp-agent";
    version = "2.5.3";
    nativeBuildInputs = [ pkgs.dpkg pkgs.autoPatchelfHook pkgs.patchelf ];
    buildInputs = runtimeLibs;

    unpackPhase = ''
      dpkg-deb -x ${cloudpanelDeb} .
    '';
    installPhase = ''
      mkdir -p $out/bin
      cp -v tmp/cloudpanel/data/clp-agent/bin/x86_64/clp-agent $out/bin/clp-agent
    '';
    postFixup = ''
      patchelf --set-interpreter ${pkgs.stdenv.cc.bintools.dynamicLinker} $out/bin/clp-agent
    '';
  };
in {
  time.timeZone = tz;

  environment.systemPackages = with pkgs; [
    clpPhp
    php83Packages.php-cs-fixer
    tzdata
    openssl
    python315
    sudo
    shadow
    coreutils
    gnugrep
    gnused
    findutils
    bash
    which
    util-linux
  ];

  users = {
    users.clp = {
      isSystemUser = true;
      group = "clp";
      home = "/var/lib/cloudpanel";
      createHome = true;
      extraGroups = [
        "mysql"
        "wheel"
        "nginx"
      ];
    };
    groups.clp = {};
  };

  services.redis.servers.cloudpanel = {
    enable = true;
    bind = "127.0.0.1";
    port = 6379;
  };

  services.mysql = {
    settings.mysqld = {
      bind_address = "127.0.0.1";
    };
    initialScript = pkgs.writeText "cloudpanel-init.sql" ''
      CREATE DATABASE IF NOT EXISTS cloudpanel
        CHARACTER SET utf8mb4
        COLLATE utf8mb4_unicode_ci;

      CREATE USER IF NOT EXISTS 'clp'@'localhost'
        IDENTIFIED VIA unix_socket;

      -- CloudPanel wants to create/manage DBs/users. Easiest is to allow it.
      GRANT ALL PRIVILEGES ON *.* TO 'clp'@'localhost' WITH GRANT OPTION;

      FLUSH PRIVILEGES;
    '';
  };

  systemd.tmpfiles.rules = [
    "d /usr/share/ 0755 root root - -"
    "f /etc/.pwd.lock 0606 root wheel -"
    "f /etc/.grp.lock 0606 root wheel -"
    "f /etc/.shadow.lock 0606 root wheel -"
    "L+ /usr/share/zoneinfo - - - - ${pkgs.tzdata}/share/zoneinfo"

    "d ${root} 0755 clp clp - -"

    "d ${stateRoot} 0750 clp clp - -"
    "d ${stateRoot}/data 0750 clp clp - -"
    "f ${stateRoot}/data/clp-agent-db.sq3 0640 clp clp - -"
    "d ${stateRoot}/var 0750 clp clp - -"
    "d ${stateRoot}/var/cache 0750 clp clp - -"
    "d ${stateRoot}/var/log 0750 clp clp - -"
    "d ${stateRoot}/var/lib 0750 clp clp - -"
    "d ${stateRoot}/var/lib/cloudpanel 0750 clp clp - -"
    "d /var/lib/cloudpanel/etc 0750 clp clp - -"
    "f /var/lib/cloudpanel/etc/.pwd.lock 0600 clp clp - -"

    # Agent logs
    "d ${stateRoot}/var/log 0750 clp clp - -"
    "f ${stateRoot}/var/log/clp-agent.log 0640 clp clp - -"

    # Logrotate (needed for cloudpanel)
    "d /etc/logrotate.d 0755 root root - -"

    # Nginx
    "d /etc/nginx/ssl-certificates 0755 nginx nginx - -"
    "d /etc/nginx/sites-enabled 0755 nginx nginx - -"

    # PHP
    "d /run/php-fpm 0755 root root - -"
    "d /etc/php 0755 root root - -"
    "d /etc/php/${phpVer} 0755 root root - -"
    "d /etc/php/${phpVer}/cli 0755 root root - -"
    "d /etc/php/${phpVer}/fpm 0755 root root - -"
    "d /etc/php/${phpVer}/fpm/pool.d 0755 root root - -"
    "d /etc/php/${phpVer}/cli/conf.d 0755 root root - -"
    "d /etc/php/${phpVer}/fpm/conf.d 0755 root root - -"
    "L+ /etc/nginx/fastcgi_params - - - - ${pkgs.nginx}/conf/fastcgi_params"
  ];

  services.logrotate = {
    enable = true;
    checkConfig = false;
    settings.header = {
      include = "/etc/logrotate.d";
    };
  };

  security.sudo = {
    enable = true;
    extraRules = [
      { users = [ "clp" ]; commands = [ { command = "ALL"; options = [ "NOPASSWD" ]; } ]; }
    ];
  };

  system.activationScripts.cloudpanelStateLinks = lib.stringAfter [ "var" ] ''
    set -eu

    install -d -m 0750 -o clp -g clp ${stateRoot}/var/cache ${stateRoot}/var/log ${stateRoot}/var/lib
    install -d -m 0755 /var/lib/cloudpanel

    app=/var/lib/cloudpanel/app
    if [ ! -e "$app" ]; then
      cp -r ${app} $app
      chown -R clp:clp $app

      rm -rf $app/var $app/data || true
      ln -sfn ${stateRoot}/var $app/var
    fi

    # Some components (agent) may write to /var/lib/cloudpanel/var relative paths.
    ln -sfn ${stateRoot}/var /var/lib/cloudpanel/var
    chown -h clp:clp /var/lib/cloudpanel/var || true

    # Fixes issues with mysql/maria, and escaping.
    cfg=$app/src/Entity/Config.php
    chmod +w "$cfg"

    ${pkgs.perl}/bin/perl -0777 -i -pe '
    s/(^\s*\*\s*)\\Column\(/$1\@ORM\\Column(/gm;

    s{
      (/\*\*.*?\@ORM\\Column\()
      (?![^)]*\bname\s*=)
      ([^)]*\)\s*\*/\s*private\s+\$key\s*;)
    }{
      $1 . q{name="`key`", } . $2
    }gsexm;

    s{
      (/\*\*.*?\@ORM\\Column\()
      (?![^)]*\bname\s*=)
      ([^)]*\)\s*\*/\s*private\s+\$value\s*;)
    }{
      $1 . q{name="`value`", } . $2
    }gsexm;
    ' "$cfg"

    install -d -m 0755 /var/lib/cloudpanel/bin

    cat > /var/lib/cloudpanel/bin/clp-useradd <<'SH'
#!/run/current-system/sw/bin/sh
set -eu

# run the real useradd
${pkgs.shadow}/bin/useradd -U "$@"

user=""
skip_next=0
for a in "$@"; do
  if [ "$skip_next" = 1 ]; then
    skip_next=0
    continue
  fi

  case "$a" in
    # options that take a following argument
    -c|-d|-e|-f|-g|-G|-k|-p|-s|-u|-K)
      skip_next=1
      ;;

    # flags that DO NOT take an argument (important: -m is a flag!)
    -m|-M|-N|-U|-o|-r)
      ;;

    # other options
    -*)
      ;;

    # candidate operand
    *)
      case "$a" in
        /*) : ;;                 # ignore paths like /home/kursu-test
        *) user="$a"; break ;;   # first non-option, non-path operand is username
      esac
      ;;
  esac
done

if [ -z "${user:-}" ]; then
  echo "clp-useradd: could not determine username from args: $*" >&2
  exit 1
fi

# allow nginx to traverse home + serve files
${pkgs.shadow}/bin/usermod -aG "$user" nginx || true

# Create expected dirs and set perms
${pkgs.coreutils}/bin/chmod 0750 "/home/$user" || true
${pkgs.coreutils}/bin/chmod 0750 "/home/$user/htdocs" "/home/$user/logs" "/home/$user/tmp" 2>/dev/null || true

${pkgs.coreutils}/bin/mkdir -p "/home/$user/logs/nginx"
${pkgs.coreutils}/bin/chown -R "$user:$user" "/home/$user"
${pkgs.coreutils}/bin/chmod 0770 "/home/$user/logs/nginx" || true
SH

    chmod 0755 /var/lib/cloudpanel/bin/clp-useradd
    chown clp:clp /var/lib/cloudpanel/bin/clp-useradd

    cat > /var/lib/cloudpanel/bin/clp-userdel <<'SH'
#!/run/current-system/sw/bin/sh
set -eu

# Find the username (last non-flag arg is usually correct)
user=""
for a in "$@"; do
  case "$a" in
    -*) : ;;
    *) user="$a" ;;
  esac
done

# Run userdel first (propagate failure)
${pkgs.shadow}/bin/userdel "$@"

# If we found a username, try to delete its private group too (ignore failures)
if [ -n "${user:-}" ]; then
  ${pkgs.shadow}/bin/groupdel "$user" >/dev/null 2>&1 || true
fi
SH

    chmod 0755 /var/lib/cloudpanel/bin/clp-userdel
    chown clp:clp /var/lib/cloudpanel/bin/clp-userdel

    # Fix the php socket
    ${pkgs.perl}/bin/perl -0777 -i -pe 's@private\s+string\s+\$template\s*=\s*".*?";@private string \$template = <<<'\'CONF\'''
[{{name}}]
listen = /run/php-fpm/{{name}}.sock
listen.owner = nginx
listen.group = nginx
listen.mode = 0660

user = {{user}}
group = {{group}}

pm = ondemand
pm.max_children = 250
pm.process_idle_timeout = 10s
pm.max_requests = 100

listen.backlog = 65535

pm.status_path = /status
request_terminate_timeout = 7200s
rlimit_files = 131072
rlimit_core = unlimited
catch_workers_output = yes
CONF
;@sg' /var/lib/cloudpanel/app/src/Site/PhpFpm/PoolBuilder.php


    # Patch tp fox getPort()
    ${pkgs.perl}/bin/perl -0777 -i -pe '
s/Dc5ce:\s*\$poolPort\s*=\s*\$latestPool->getPort\(\)\s*\+\s*1\s*;/
Dc5ce: \$poolPort = ((\$latestPool && \$latestPool->getPort() !== null) ? (int)\$latestPool->getPort() : 9000) + 1;/g
' "/var/lib/cloudpanel/app/src/Site/Creator/PhpSite.php"

    # Patch tp fox getPort() (updater)
    ${pkgs.perl}/bin/perl -0777 -i -pe '
s/E0405:\s*\$poolPort\s*=\s*\$latestPool->getPort\(\)\s*\+\s*1\s*;/
E0405: \$poolPort = ((\$latestPool && \$latestPool->getPort() !== null) ? (int)\$latestPool->getPort() : 9000) + 1;/g
' "/var/lib/cloudpanel/app/src/Site/Updater/PhpSite.php"

    # Patch updateNginxVhostWithRollback
    ${pkgs.perl}/bin/perl -0777 -i -pe 'BEGIN{$ins=q{
$domainName = $this->site->getDomainName();
$vhostContent = preg_replace(
  "\x7e\x66\x61\x73\x74\x63\x67\x69\x5f\x73\x65\x6e\x64\x5f\x74\x69\x6d\x65\x6f\x75\x74\x5c\x73\x2b\x33\x36\x30\x30\x3b\x7e",
  "\x66\x61\x73\x74\x63\x67\x69\x5f\x73\x65\x6e\x64\x5f\x74\x69\x6d\x65\x6f\x75\x74\x20\x33\x36\x30\x30\x3b\x0a\x20\x20\x20\x20\x66\x61\x73\x74\x63\x67\x69\x5f\x70\x61\x73\x73\x20\x75\x6e\x69\x78\x3a\x2f\x72\x75\x6e\x2f\x70\x68\x70\x2d\x66\x70\x6d\x2f".$domainName."\x2e\x73\x6f\x63\x6b\x3b",
  $vhostContent,
  1
);
};}
s{(bcb1d:\s*\$vhostContent\s*=\s*\$vhostTemplate->getContent\(\);\s*goto\s*fbfe7;)}{$1.$ins}se' \
/var/lib/cloudpanel/app/src/Site/Updater.php

    ${pkgs.perl}/bin/perl -0777 -i -pe 'BEGIN{$ins=q{
$domainName = $this->site->getDomainName();
$vhostContent = preg_replace(
  "\x7e\x66\x61\x73\x74\x63\x67\x69\x5f\x73\x65\x6e\x64\x5f\x74\x69\x6d\x65\x6f\x75\x74\x5c\x73\x2b\x33\x36\x30\x30\x3b\x7e",
  "\x66\x61\x73\x74\x63\x67\x69\x5f\x73\x65\x6e\x64\x5f\x74\x69\x6d\x65\x6f\x75\x74\x20\x33\x36\x30\x30\x3b\x0a\x20\x20\x20\x20\x66\x61\x73\x74\x63\x67\x69\x5f\x70\x61\x73\x73\x20\x75\x6e\x69\x78\x3a\x2f\x72\x75\x6e\x2f\x70\x68\x70\x2d\x66\x70\x6d\x2f".$domainName."\x2e\x73\x6f\x63\x6b\x3b",
  $vhostContent,
  1
);
};}
s{(bcb1d:\s*\$vhostContent\s*=\s*\$vhostTemplate->getContent\(\);\s*goto\s*fbfe7;)}{$1.$ins}se' \
/var/lib/cloudpanel/app/src/Site/Updater.php

    # Patch to allow {{php_fpm_port}} to be a socket
    ${pkgs.perl}/bin/perl -0777 -i -pe '
s/\Q$placeholderValue = $phpSettings->getPoolPort();\E/
$domainName = $this->site->getDomainName(); $placeholderValue = "unix:\/run\/php-fpm\/" . $domainName . ".sock";/g
' "/var/lib/cloudpanel/app/src/Site/Nginx/Vhost/Processor/PhpFpmPort.php"

    execf=$app/src/System/CommandExecutor.php
    chmod +w "$execf"

    cat > /var/lib/cloudpanel/app/src/System/CommandExecutor.php <<'PHP'
<?php

namespace App\System;

use Symfony\Component\Process\Process;

class CommandExecutor
{
    public function execute(Command $command, $timeout = 30) : void
    {
        $fullCommand = $command->getCommand();
        // Build a rewritten command line
        $cmd = $this->rewriteForNix($fullCommand);
        try {
            $runInBackground = $command->runInBackground();
            $process = Process::fromShellCommandline($cmd, "/tmp/");

            $process->setEnv(array_merge(
                $_ENV,
                $_SERVER,
                [
                    "PATH" => "/run/current-system/sw/bin:/run/wrappers/bin:/usr/bin:/bin",
                ]
            ));

            if ($runInBackground === true) {
                $process->start();
            } else {
                $process->setTimeout($timeout);
                $process->run();

                if ($process->isSuccessful() === false) {
                    throw new \RuntimeException($process->getErrorOutput());
                }
            }
        } catch (\Exception $e) {
            $errorMessage = sprintf(
                "Command \"%s, \"patched: %s\" : %s\" failed, error message: %s",
                $command->getName(),
                $cmd,
                $fullCommand,
                $e->getMessage()
            );
            throw new \Exception($errorMessage);
        }
    }

    private function rewriteForNix(string $cmd) : string
    {
        // Ensure patching is consistent
        $cmd = str_replace("/usr/bin", "/bin", $cmd);
        $cmd = str_replace("/usr/sbin", "/bin", $cmd);

        // Sudo
        $cmd = str_replace("/bin/sudo", "/run/wrappers/bin/sudo -n", $cmd);

        // OpenSSL
        $cmd = str_replace("/bin/openssl", "${pkgs.openssl_3}/bin/openssl", $cmd);

        // Shadow tools
        $cmd = str_replace("/bin/useradd", "/var/lib/cloudpanel/bin/clp-useradd", $cmd);
        $cmd = str_replace("/bin/userdel", "/var/lib/cloudpanel/bin/clp-userdel", $cmd);
        $cmd = str_replace("/bin/usermod", "${pkgs.shadow}/bin/usermod", $cmd);

        // Coreutils
        $cmd = str_replace("/bin/cat", "${pkgs.coreutils}/bin/cat", $cmd);
        $cmd = str_replace("/bin/mkdir", "${pkgs.coreutils}/bin/mkdir", $cmd);
        $cmd = str_replace("/bin/chown", "${pkgs.coreutils}/bin/chown", $cmd);
        $cmd = str_replace("/bin/chmod", "${pkgs.coreutils}/bin/chmod", $cmd);
        $cmd = str_replace("/bin/cp", "${pkgs.coreutils}/bin/cp", $cmd);
        $cmd = str_replace("/bin/mv", "${pkgs.coreutils}/bin/mv", $cmd);
        $cmd = str_replace("/bin/rm", "${pkgs.coreutils}/bin/rm", $cmd);
        $cmd = str_replace("/bin/ln", "${pkgs.coreutils}/bin/ln", $cmd);
        $cmd = str_replace("/bin/touch", "${pkgs.coreutils}/bin/touch", $cmd);
        $cmd = str_replace("/bin/chgrp", "${pkgs.coreutils}/bin/chgrp", $cmd);
        $cmd = str_replace("/bin/tee", "${pkgs.coreutils}/bin/tee", $cmd);

        // Systemd
        $cmd = str_replace("/bin/timedatectl", "${pkgs.systemd}/bin/timedatectl", $cmd);

        // Findutils
        $cmd = str_replace("/bin/find", "${pkgs.findutils}/bin/find", $cmd);
        $cmd = str_replace("/bin/locate", "${pkgs.findutils}/bin/locate", $cmd);
        $cmd = str_replace("/bin/updatedb", "${pkgs.findutils}/bin/updatedb", $cmd);
        $cmd = str_replace("/bin/xargs", "${pkgs.findutils}/bin/xargs", $cmd);

        // Grep
        $cmd = str_replace("/bin/grep", "${pkgs.gnugrep}/bin/grep", $cmd);

        // Nginx
        $cmd = str_replace("/bin/nginx", "${config.services.nginx.package}/bin/nginx -c /etc/nginx/nginx.conf", $cmd);

        // Shell
        $cmd = str_replace("/bin/bash", "${pkgs.bash}/bin/bash", $cmd);
        $cmd = str_replace("/bin/sh", "${pkgs.bash}/bin/sh", $cmd);

        // Serialize passwd modifications (CloudPanel may run these concurrently)
        if (preg_match('~\b(useradd|usermod|userdel|groupadd|groupmod|groupdel|passwd|chpasswd)\b~', $cmd)) {
            $lockfile = "/var/lib/cloudpanel/etc/.pwd.lock";
            $python = "${pkgs.python3}/bin/python3";

            $cmd = $python . " -c " . escapeshellarg(<<<'PY'
import fcntl, os, sys, time
lockfile = sys.argv[1]
timeout  = float(sys.argv[2])
argv = sys.argv[3:]
if argv and argv[0] == "--":
    argv = argv[1:]
if not argv:
    raise SystemExit("no command")

# Open read-only so RO mounts don't break us.
fd = os.open(lockfile, os.O_RDONLY)
deadline = time.time() + timeout
while True:
    try:
        fcntl.flock(fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
        break
    except BlockingIOError:
        if time.time() >= deadline:
            raise SystemExit(f"timeout acquiring lock: {lockfile}")
        time.sleep(0.1)

os.execvp(argv[0], argv)
PY
            ) . " " . escapeshellarg($lockfile) . " 30 -- " . $cmd;
        }

        return $cmd;
    }
}
PHP

    rm -rf "$app/var/cache/"* || true
  '';

  systemd.services.ensure-cloudpanel-db = {
    description = "Ensure CloudPanel's database exists";
    wantedBy = [ "multi-user.target" ];
    after = [ "mysql.service" ];
    requires = [ "mysql.service" ];
    serviceConfig = {
      Type = "oneshot";
      User = "clp";
      Group = "clp";
    };

    script = ''
      set -eu

      sock=/run/mysqld/mysqld.sock

      # Wait briefly for socket to appear (mariadb startup)
      for i in $(seq 1 60); do
        if [ -S "$sock" ]; then
          break
        fi
        sleep 0.2
      done

      if [ ! -S "$sock" ]; then
        echo "MariaDB socket not available: $sock" >&2
        exit 1
      fi

      marker=${stateRoot}/.db-initialized
      marker_2=${stateRoot}/.db-fixtures-initialized

      if [ ! -e "$marker" ]; then
        echo "Initializing CloudPanel database..."
        ${pkgs.sudo}/bin/sudo -u clp env -i \
          PATH=/run/current-system/sw/bin \
          APP_ENV=dev APP_DEBUG=1 TZ=${tz} \
          DATABASE_URL=${config.services.phpfpm.pools.cloudpanel.phpEnv.DATABASE_URL} \
          ${config.services.phpfpm.pools.cloudpanel.phpPackage}/bin/php \
          /var/lib/cloudpanel/app/bin/console doctrine:schema:create
        touch "$marker"
      fi

      if [ ! -e "$marker_2" ]; then
        echo "Finalizing CloudPanel database creation..."
        ${pkgs.sudo}/bin/sudo -u clp env -i \
          PATH=/run/current-system/sw/bin \
          APP_ENV=dev APP_DEBUG=1 TZ=${tz} \
          DATABASE_URL=${config.services.phpfpm.pools.cloudpanel.phpEnv.DATABASE_URL} \
          ${config.services.phpfpm.pools.cloudpanel.phpPackage}/bin/php \
          /var/lib/cloudpanel/app/bin/console doctrine:fixtures:load --no-interaction
        touch "$marker_2"
      fi

      ${pkgs.mariadb}/bin/mariadb -S "$sock" cloudpanel <<'SQL'
INSERT INTO database_server
  (created_at, updated_at, is_active, is_default, engine, version, host, user_name, password, certificate, port)
SELECT
  NOW(), NOW(), 1, 1, 'mysql', 'mariadb', 'localhost', 'clp', CONCAT('''), CONCAT('''), 3306
WHERE NOT EXISTS (SELECT 1 FROM database_server);

INSERT INTO vhost_template
  (created_at, updated_at, name, template, root_directory, php_version, varnish_cache_settings, type)
SELECT
  NOW(), NOW(),
  'Static',
'server {
  listen 80;
  listen [::]:80;
  listen 443 quic;
  listen 443 ssl;
  listen [::]:443 quic;
  listen [::]:443 ssl;
  http2 on;
  http3 off;
  {{ssl_certificate_key}}
  {{ssl_certificate}}
  {{server_name}}
  {{root}}

  {{nginx_access_log}}
  {{nginx_error_log}}

  if ($scheme != "https") {
    rewrite ^ https://$host$request_uri permanent;
  }

  location ~ /.well-known {
    auth_basic off;
    allow all;
  }

  {{settings}}

  index index.html;

  location ~* ^.+\.(css|js|jpg|jpeg|gif|png|ico|gz|svg|svgz|ttf|otf|woff|woff2|eot|mp4|ogg|ogv|webm|webp|zip|swf)$ {
    add_header Access-Control-Allow-Origin "*";
    add_header alt-svc "h3=\":443\"; ma=86400";
    expires max;
    access_log off;
  }

  if (-f $request_filename) {
    break;
  }
}',
  NULL, NULL, NULL,
  COALESCE((SELECT MIN(type) FROM vhost_template), 0)
WHERE NOT EXISTS (SELECT 1 FROM vhost_template WHERE name = 'Static');

INSERT INTO vhost_template
  (created_at, updated_at, name, template, root_directory, php_version, varnish_cache_settings, type)
SELECT
  NOW(), NOW(),
  'Generic',
'server {
  listen 80;
  listen [::]:80;
  listen 443 ssl http2;
  listen [::]:443 ssl http2;
  {{ssl_certificate_key}}
  {{ssl_certificate}}
  {{server_name}}
  {{root}}

  {{nginx_access_log}}
  {{nginx_error_log}}

  if ($scheme != "https") {
    rewrite ^ https://$host$uri permanent;
  }

  location ~ /.well-known {
    auth_basic off;
    allow all;
  }

  {{basic_auth}}

  try_files $uri $uri/ /index.php?$args;
  index index.php index.html;

  location ~ \.php$ {
    include fastcgi_params;
    fastcgi_intercept_errors on;
    fastcgi_index index.php;
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    try_files $uri =404;
    fastcgi_read_timeout 3600;
    fastcgi_send_timeout 3600;
    {{php_fpm_listener}}
  }

  location ~* ^.+\.(css|js|jpg|jpeg|gif|png|ico|gz|svg|svgz|ttf|otf|woff|eot|mp4|ogg|ogv|webm|webp|zip|swf)$ {
    add_header Access-Control-Allow-Origin "*";
    expires max;
    access_log off;
  }

  if (-f $request_filename) {
    break;
  }
}',
  NULL, NULL, NULL,
  COALESCE((SELECT MIN(type) FROM vhost_template), 0)
WHERE NOT EXISTS (SELECT 1 FROM vhost_template WHERE name = 'Generic');
SQL
    '';
  };

  services.phpfpm.pools.cloudpanel = {
    user = "clp";
    group = "clp";
    phpPackage = clpPhp;

    phpOptions = ''
      date.timezone = ${tz}
      zend_extension=${ioncube}/lib/php/extensions/ioncube-loader.so
      max_execution_time = 200
      memory_limit = 512M
      upload_max_filesize = 64M
      post_max_size = 64M
    '';

    settings = {
      "listen.owner" = "nginx";
      "listen.group" = "nginx";
      "listen.mode" = "0660";
      "pm" = "dynamic";
      "pm.max_children" = 20;
      "pm.start_servers" = 2;
      "pm.min_spare_servers" = 2;
      "pm.max_spare_servers" = 6;
    };

    phpEnv = {
      # Due to the equals statement in php-fqm, this is needed
      DATABASE_URL = "\"mysql://clp@localhost/cloudpanel?unix_socket=/run/mysqld/mysqld.sock\"";
      APP_ENV = "dev";
      APP_DEBUG = "1";
      TZ = tz;
    };
  };

  system.activationScripts.cloudpanelPhpFpmDebianCompat = lib.stringAfter [ "etc" ] ''
    set -eu

    cat > ${fpmEtc}/php-fpm.conf <<'CONF'
[global]
pid = /run/php-fpm/php8.3-fpm.pid
error_log = /var/log/php8.3-fpm.log

include=/etc/php/8.3/fpm/pool.d/*.conf
CONF

    cat > ${fpmEtc}/pool.d/00-seed.conf <<'CONF'
[seed]
user = clp
group = clp
listen = 127.0.0.1:9000
pm = dynamic
pm.max_children = 4
pm.start_servers = 1
pm.min_spare_servers = 1
pm.max_spare_servers = 2
CONF

    # log file
    install -m 0644 -o root -g root /dev/null /var/log/php8.3-fpm.log || true
  '';

  systemd.services."php8.3-fpm" = {
    description = "CloudPanel PHP-FPM 8.3 (reads /etc/php/8.3/fpm/pool.d)";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${clpPhp}/bin/php-fpm --nodaemonize --fpm-config /etc/php/8.3/fpm/php-fpm.conf";
      Restart = "always";
      RestartSec = "1s";

      ReadWritePaths = [ "/etc/php" "/run/php-fpm" "/var/log" "/home" "/var/lib/cloudpanel" ];
    };
  };

  systemd.services.phpfpm-cloudpanel.serviceConfig = {
    ProtectHome = lib.mkForce false;
    ProtectSystem = lib.mkForce "false";
    ReadWritePaths = [
      "/etc"
      "/home"
      "/var/lib/cloudpanel"
      "/var/lib/cloudpanel/state"
      "/var/lib/cloudpanel/etc"
    ];
  };

  services.nginx = {
    enable = true;

    appendHttpConfig = ''
      # CloudPanel expects this
      log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

      include /etc/nginx/sites-enabled/*.conf;
    '';

    virtualHosts."panel.kursu.dev" = {
      forceSSL = true;
      enableACME = true;

      root = "/var/lib/cloudpanel/app/public";

      extraConfig = ''
        index index.php;
      '';

      locations."/" = {
        tryFiles = "$uri /index.php$is_args$args";
      };

      locations."~ \\.php$" = {
        extraConfig = ''
          include ${pkgs.nginx}/conf/fastcgi_params;
          fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
          fastcgi_pass unix:${config.services.phpfpm.pools.cloudpanel.socket};
        '';
      };

      locations."~* /(\\.env|\\.git|composer\\.(json|lock)|vendor/|var/|config/)" = {
        extraConfig = "deny all;";
      };
    };
  };

  systemd.services.nginx.serviceConfig.ProtectHome = "no";
  systemd.services.clp-agent-initdb = {
    description = "Initialize CloudPanel agent SQLite DB";
    wantedBy = [ "multi-user.target" ];
    before = [ "clp-agent.service" ];
    serviceConfig = {
      Type = "oneshot";
      User = "clp";
      Group = "clp";
    };
    script = ''
      set -eu
      db=${stateRoot}/data/clp-agent-db.sq3
      ${pkgs.sqlite}/bin/sqlite3 "$db" <<'SQL'
PRAGMA journal_mode=WAL;
PRAGMA foreign_keys=ON;

CREATE TABLE IF NOT EXISTS instance_load_average (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  created_at TEXT NOT NULL,
  period INTEGER NOT NULL,
  value REAL NOT NULL
);

CREATE TABLE IF NOT EXISTS instance_disk_usage (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  created_at TEXT NOT NULL,
  disk TEXT NOT NULL,
  value REAL NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_ila_created_at ON instance_load_average(created_at);
CREATE INDEX IF NOT EXISTS idx_idu_created_at ON instance_disk_usage(created_at);
SQL
    '';
  };

  systemd.services.clp-agent = {
    description = "CloudPanel Agent";
    wantedBy = [ "multi-user.target" ];
    after = [ "ensure-cloudpanel-db.service" "clp-agent-initdb.service" ];
    wants = [ "ensure-cloudpanel-db.service" "clp-agent-initdb.service" ];
    serviceConfig = {
      Type = "simple";
      User = "clp";
      Group = "clp";
      UMask = "0027";
      WorkingDirectory = "/var/lib/cloudpanel";

      Environment = [
        "DATABASE_URL=${stateRoot}/data/clp-agent-db.sq3"
      ];

      ExecStartPre = [
        "${pkgs.coreutils}/bin/install -o clp -g clp -m 0640 /dev/null ${stateRoot}/var/log/clp-agent.log"
      ];

      ReadWritePaths = [
        "/run/mysqld"
      ];

      ExecStart = "${clpAgent}/bin/clp-agent -v -l /var/lib/cloudpanel/state/var/log/clp-agent.log";
      Restart = "always";
      RestartSec = "2s";
    };
  };
}