{ config
, lib
, pkgs
, ... }:

let
  inherit (lib) mkEnableOption mkOption mkIf types;

  r = config.router;
  cfg = config.services.bindLocalnet;

  parseExtraHosts =
    zoneDomain: text:
    let
      lines =
        builtins.filter (l: l != "" && !(lib.hasPrefix "#" l))
          (builtins.map lib.strings.trim (lib.strings.splitString "\n" text));

      parseLine = line:
        let
          toks =
            builtins.filter (t: t != "")
              (lib.strings.splitString " "
                (lib.strings.replaceStrings ["\t"] [" "] line));

          ip = builtins.elemAt toks 0;
          rawNames = lib.lists.drop 1 toks;

          normName = n: let n0 = lib.strings.removeSuffix "." n; in
            if lib.hasSuffix ".${zoneDomain}" n0 then
              lib.strings.removeSuffix ".${zoneDomain}" n0
            else if builtins.match ".*\\..*" n0 == null then
              n0
            else
              null;

          normalized = builtins.filter (n: n != null) (builtins.map normName rawNames);
          names = if normalized == [] then [] else [ (builtins.elemAt normalized 0) ];
        in
          if names == [] then null else { inherit ip names; };

      entries = builtins.filter (e: e != null) (builtins.map parseLine lines);
    in
      entries;

  entries = parseExtraHosts cfg.zoneDomain (config.networking.extraHosts or "");

  aLines =
    lib.concatStringsSep "\n"
      (lib.flatten (builtins.map
        (e: builtins.map (n: "${n} IN A ${e.ip}") e.names)
        entries));

  ptrLines =
    lib.concatStringsSep "\n"
      (lib.unique (builtins.map
        (e:
          let
            octets = lib.strings.splitString "." e.ip;
            last = builtins.elemAt octets 3;
            canonical = builtins.elemAt e.names 0;
          in "${last} IN PTR ${canonical}.${cfg.zoneDomain}.")
        (builtins.filter (e: lib.hasPrefix "${r.lanSubnet}." e.ip) entries)));

  forwardZoneText = ''
    $TTL 1h
    @ IN SOA ns1.${cfg.zoneDomain}. admin.${cfg.zoneDomain}. (
      ${cfg.zoneSerial}  ; serial
      1h             ; refresh
      15m            ; retry
      30d            ; expire
      2h             ; negative cache
    )
    @   IN NS  ns1.${cfg.zoneDomain}.
    ns1 IN A   ${cfg.ns1IPv4}

    ${aLines}
  '';

  reverseZoneText = ''
    $TTL 1h
    @ IN SOA ns1.${cfg.zoneDomain}. admin.${cfg.zoneDomain}. (
      ${cfg.zoneSerial} 1h 15m 30d 2h
    )
    @ IN NS ns1.${cfg.zoneDomain}.

    ${ptrLines}
  '';

  rpzLines = lib.concatStringsSep "\n" (builtins.map (d: "${d} CNAME .") cfg.rpzCnames);

  rpzZoneText = ''
    $TTL 60
    @ IN SOA ns1.${cfg.zoneDomain}. admin.${cfg.zoneDomain}. (
      ${cfg.zoneSerial} 1h 15m 30d 2h
    )
    @ IN NS ns1.${cfg.zoneDomain}.

    ${rpzLines}
  '';

  forwardZoneFile = "/var/lib/named/${cfg.zoneDomain}.zone";
  reverseZoneFile = "/var/lib/named/${cfg.reverseZoneName}.rev";
  rpzZoneFile = "/var/lib/named/${cfg.rpzZoneName}.zone";

  publicV6 = "2601:406:8180:35a7";
in {
  options.services.bindLocalnet = {
    enable = mkEnableOption "BIND authoritative local zone + RPZ based on networking.extraHosts";

    lanInterface = mkOption {
      type = types.str;
      description = "Ethernet interface serving DNS";
    };

    zoneDomain = mkOption {
      type = types.str;
      default = "localnet";
      description = "Authoritative forward zone domain.";
    };

    zoneSerial = mkOption {
      type = types.str;
      default = "2026021701";
      description = "SOA serial for generated zones.";
    };

    ns1IPv4 = mkOption {
      type = types.str;
      default = "${r.lanSubnet}.1";
      description = "IPv4 address for ns1.${cfg.zoneDomain}.";
    };

    reverseZoneName = mkOption {
      type = types.str;
      default = "10.0.0";
      description = "Reverse zone prefix name (used for file naming only).";
    };

    reverseZone = mkOption {
      type = types.str;
      default = "0.0.10.in-addr.arpa";
      description = "Reverse zone domain served by BIND.";
    };

    rpzZoneName = mkOption {
      type = types.str;
      default = "rpz.local";
      description = "RPZ zone name (also used as the zone key in services.bind.zones).";
    };

    rpzCnames = mkOption {
      type = types.listOf types.str;
      default = [];
      example = [
        "ads.roku.com"
        "identity.ads.roku.com"
        "securepubads.g.doubleclick.net"
      ];
      description = ''
        Domains to block via RPZ. Each entry becomes:
          "<domain> CNAME ."
      '';
    };

    cacheNetworks = mkOption {
      type = types.listOf types.str;
      default = [
        "127.0.0.0/8"
        "::1/128"
        "${r.lanSubnet}.0/24"
        "${r.lanSubnetV6}::/64"
        "${publicV6}::/64"
      ];
      description = "BIND cacheNetworks (clients allowed to use cache).";
    };

    forwarders = mkOption {
      type = types.listOf types.str;
      default = [
        "8.8.8.8"
        "8.8.4.4"
        "1.1.1.1"
        "1.0.0.1"
        "2001:4860:4860::8888"
        "2606:4700:4700::1111"
        "2606:4700:4700::1001"
      ];
      description = "Upstream recursive forwarders.";
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.interfaces.${cfg.lanInterface} = {
      allowedTCPPorts = [ 53 ];
      allowedUDPPorts = [ 53 ];
    };

    environment.systemPackages = [
      pkgs.bind
    ];

    services.bind = {
      enable = true;

      cacheNetworks = cfg.cacheNetworks;
      forwarders = cfg.forwarders;

      extraConfig = ''
        statistics-channels {
          inet 127.0.0.1 port 8053 allow { 127.0.0.1; };
        };
      '';

      extraOptions = ''
        allow-recursion {
          127.0.0.1;
          ::1;
          ${r.lanSubnet}.0/24;
          ${r.lanSubnetV6}::/64;
          ${publicV6}::/64;
        };
        dnssec-validation auto;
        listen-on { any; };
        listen-on-v6 { any; };
        minimal-responses yes;
        response-policy { zone "${cfg.rpzZoneName}"; };
      '';

      zones = {
        ${cfg.zoneDomain} = {
          master = true;
          file = forwardZoneFile;
        };

        ${cfg.reverseZone}  = {
          master = true;
          file = reverseZoneFile;
        };

        ${cfg.rpzZoneName} = {
          master = true;
          file = rpzZoneFile;
        };
      };
    };

    systemd.services.bind = {
      requires = [ "bind-zones.service" ];
      after = [ "bind-zones.service" ];
    };

    systemd.services.bind-zones = {
      description = "Install BIND zone files";
      wantedBy = [ "multi-user.target" ];
      before = [ "bind.service" ];
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
      script = ''
        set -euo pipefail
        install -d -m 0750 -o named -g named /var/lib/named

        cat > ${forwardZoneFile} <<'EOF'
${forwardZoneText}
EOF

        cat > ${reverseZoneFile} <<'EOF'
${reverseZoneText}
EOF

        cat > ${rpzZoneFile} <<'EOF'
${rpzZoneText}
EOF

        chown named:named ${forwardZoneFile} ${reverseZoneFile} ${rpzZoneFile}
        chmod 0640 ${forwardZoneFile} ${reverseZoneFile} ${rpzZoneFile}

        ${pkgs.bind}/bin/named-checkzone ${cfg.zoneDomain} ${forwardZoneFile}
        ${pkgs.bind}/bin/named-checkzone ${cfg.reverseZone} ${reverseZoneFile}
        ${pkgs.bind}/bin/named-checkzone ${cfg.rpzZoneName} ${rpzZoneFile}
      '';
    };

    services.kresd.enable = lib.mkForce false;
    services.kresd.instances = 0;
  };
}