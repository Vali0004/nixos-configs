{ config
, lib
, pkgs
, ... }:

let
  inherit (lib) mkEnableOption mkOption mkIf types;

  r = config.router;
  cfg = config.services.bindLocalnet;

  allowedRecursionCidrs = [
    "127.0.0.0/8"
    "::1/128"
    "${r.lanSubnet}.0/24"
    "${r.lanSubnetV6}::/64"
  ] ++ lib.optional (cfg.publicV6Prefix != null) "${cfg.publicV6Prefix}::/64";

  parseExtraHosts =
    zoneDomain: text:
    let
      lines =
        builtins.filter
          (l: l != "" && !(lib.hasPrefix "#" l))
          (builtins.map lib.strings.trim (lib.strings.splitString "\n" text));

      parseLine = line:
        let
          toks =
            builtins.filter
              (t: t != "")
              (lib.strings.splitString " "
                (lib.strings.replaceStrings [ "\t" ] [ " " ] line));

          tokCount = builtins.length toks;
        in
          if tokCount < 2 then
            null
          else
            let
              ip = builtins.elemAt toks 0;
              rawNames = lib.lists.drop 1 toks;

              normName = n:
                let
                  n0 = lib.strings.removeSuffix "." n;
                in
                  if lib.hasSuffix ".${zoneDomain}" n0 then
                    lib.strings.removeSuffix ".${zoneDomain}" n0
                  else if builtins.match ".*\\..*" n0 == null then
                    n0
                  else
                    null;

              normalized =
                builtins.filter (n: n != null) (builtins.map normName rawNames);

              names = lib.unique normalized;
            in
              if names == [] then null else { inherit ip names; };

      entries = builtins.filter (e: e != null) (builtins.map parseLine lines);
    in
      entries;

  entries = parseExtraHosts cfg.zoneDomain (config.networking.extraHosts or "");

  aLines =
    lib.concatStringsSep "\n" (
      lib.flatten (
        builtins.map
          (e: builtins.map (n: "${n} IN A ${e.ip}") e.names)
          entries
      )
    );

  ptrEntries =
    builtins.filter
      (e:
        let
          octets = lib.strings.splitString "." e.ip;
        in
          (builtins.length octets == 4)
          && lib.hasPrefix "${r.lanSubnet}." e.ip
      )
      entries;

  ptrLines =
    lib.concatStringsSep "\n" (
      lib.unique (
        builtins.map
          (e:
            let
              octets = lib.strings.splitString "." e.ip;
              last = builtins.elemAt octets 3;
              canonical = builtins.elemAt e.names 0;
            in
              "${last} IN PTR ${canonical}.${cfg.zoneDomain}.")
          ptrEntries
      )
    );

  forwardZoneFile = pkgs.writeText "${cfg.zoneDomain}.zone" ''
    $TTL 1h
    @ IN SOA ns1.${cfg.zoneDomain}. admin.${cfg.zoneDomain}. (
      ${cfg.zoneSerial}  ; serial
      1h                 ; refresh
      15m                ; retry
      30d                ; expire
      2h                 ; negative cache
    )
    @   IN NS  ns1.${cfg.zoneDomain}.
    ns1 IN A   ${cfg.ns1IPv4}

    ${aLines}
  '';

  reverseZoneFile = pkgs.writeText "${cfg.reverseZone}.zone" ''
    $TTL 1h
    @ IN SOA ns1.${cfg.zoneDomain}. admin.${cfg.zoneDomain}. (
      ${cfg.zoneSerial}  ; serial
      1h                 ; refresh
      15m                ; retry
      30d                ; expire
      2h                 ; negative cache
    )
    @ IN NS ns1.${cfg.zoneDomain}.

    ${ptrLines}
  '';

  rpzLines =
    lib.concatStringsSep "\n" (
      builtins.map (d: "${d} CNAME .") cfg.rpzCnames
    );

  rpzZoneFile = pkgs.writeText "${cfg.rpzZoneName}.zone" ''
    $TTL 60
    @ IN SOA ns1.${cfg.zoneDomain}. admin.${cfg.zoneDomain}. (
      ${cfg.zoneSerial}  ; serial
      1h                 ; refresh
      15m                ; retry
      30d                ; expire
      2h                 ; negative cache
    )
    @ IN NS ns1.${cfg.zoneDomain}.

    ${rpzLines}
  '';
in {
  options.services.bindLocalnet = {
    enable = mkEnableOption "BIND authoritative local zone + RPZ based on networking.extraHosts";

    lanInterface = mkOption {
      type = types.str;
      description = "Interface serving DNS to the LAN.";
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

    reverseZone = mkOption {
      type = types.str;
      default = "0.0.10.in-addr.arpa";
      description = "Reverse zone domain served by BIND.";
    };

    rpzZoneName = mkOption {
      type = types.str;
      default = "rpz.local";
      description = "RPZ zone name.";
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

    publicV6Prefix = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "2601:406:8180:35a7";
      description = ''
        Optional static public IPv6 /64 prefix allowed to use recursion.
        Kept explicit for reproducible remote deploys.
      '';
    };

    recursionCidrs = mkOption {
      type = types.listOf types.str;
      default = allowedRecursionCidrs;
      defaultText = lib.literalExpression ''
        [
          "127.0.0.0/8"
          "::1/128"
          "\${config.router.lanSubnet}.0/24"
          "\${config.router.lanSubnetV6}::/64"
        ] ++ optional publicV6Prefix
      '';
      description = "Networks allowed to use cache and recursion.";
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

    environment.systemPackages = [ pkgs.bind ];

    services.bind = {
      enable = true;

      cacheNetworks = cfg.recursionCidrs;
      forwarders = cfg.forwarders;

      extraConfig = ''
        statistics-channels {
          inet 127.0.0.1 port 8053 allow { 127.0.0.1; };
        };
      '';

      extraOptions = ''
        allow-recursion {
          ${lib.concatStringsSep ";\n          " cfg.recursionCidrs};
        };
        dnssec-validation auto;
        listen-on { any; };
        listen-on-v6 { any; };
        minimal-responses yes;
        response-policy { zone "${cfg.rpzZoneName}"; };
        max-recursion-queries 1000;
        recursive-clients 1000;
        resolver-query-timeout 10;
      '';

      zones = {
        ${cfg.zoneDomain} = {
          master = true;
          file = forwardZoneFile;
        };

        ${cfg.reverseZone} = {
          master = true;
          file = reverseZoneFile;
        };

        ${cfg.rpzZoneName} = {
          master = true;
          file = rpzZoneFile;
        };
      };
    };

    services.kresd.enable = lib.mkForce false;
    services.kresd.instances = 0;
  };
}