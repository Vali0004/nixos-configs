{ config
, lib
, pkgs
, ... }:

let
  cfg = config.router;
  zoneDomain = "localnet";
  zoneSerial = "2026021701";

  parseExtraHosts =
    text:
    let
      lines =
        builtins.filter (l: l != "" && !(lib.hasPrefix "#" l))
          (builtins.map lib.strings.trim (lib.strings.splitString "\n" text));

      parseLine = line:
        let
          toks = builtins.filter (t: t != "") (lib.strings.splitString " " (lib.strings.replaceStrings ["\t"] [" "] line));
          ip = builtins.elemAt toks 0;
          rawNames = lib.lists.drop 1 toks;
          normName = n:
            let
              n0 = lib.strings.removeSuffix "." n;
            in
              if lib.hasSuffix ".${zoneDomain}" n0
              then lib.strings.removeSuffix ".${zoneDomain}" n0
              else if builtins.match ".*\\..*" n0 == null
              then n0
              else null;
          names =
            let
              normalized = builtins.filter (n: n != null) (builtins.map normName rawNames);
            in
              if normalized == [] then [] else [ (builtins.elemAt normalized 0) ];
        in
          if names == [] then null else { inherit ip names; };

      entries = builtins.filter (e: e != null) (builtins.map parseLine lines);
    in
      entries;

  entries = parseExtraHosts config.networking.extraHosts;

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
          in "${last} IN PTR ${canonical}.${zoneDomain}.")
        (builtins.filter (e: lib.hasPrefix "10.0.0." e.ip) entries)));

  forwardZoneText = ''
    $TTL 1h
    @ IN SOA ns1.${zoneDomain}. admin.${zoneDomain}. (
      ${zoneSerial}  ; serial
      1h             ; refresh
      15m            ; retry
      30d            ; expire
      2h             ; negative cache
    )
    @   IN NS  ns1.${zoneDomain}.
    ns1 IN A   10.0.0.1

    ${aLines}
  '';

  reverseZoneText = ''
    $TTL 1h
    @ IN SOA ns1.${zoneDomain}. admin.${zoneDomain}. (
      ${zoneSerial} 1h 15m 30d 2h
    )
    @ IN NS ns1.${zoneDomain}.

    ${ptrLines}
  '';

  rpzZoneText = ''
    $TTL 60
    @ IN SOA ns1.localnet. admin.localnet. (
      2026021701 1h 15m 30d 2h
    )
    @ IN NS ns1.localnet.

    ads.roku.com                    CNAME .
    identity.ads.roku.com           CNAME .
    logs.roku.com                   CNAME .
    austin.logs.roku.com            CNAME .
    cooper.logs.roku.com            CNAME .
    giga.logs.roku.com              CNAME .
    liberty.logs.roku.com           CNAME .
    scribe.logs.roku.com            CNAME .
    tyler.logs.roku.com             CNAME .
    cloudservices.roku.com          CNAME .
    customer-feedbacks.web.roku.com CNAME .
    ravm.tv                         CNAME .
    display.ravm.tv                 CNAME .
    p.ravm.tv                       CNAME .
    adsmeasurement.com              CNAME .
    roku.adsmeasurement.com         CNAME .
    securepubads.g.doubleclick.net  CNAME .
    lat-services.api.data.roku.com  CNAME .
    tpc.googlesyndication.com       CNAME .
  '';
in {
  networking.firewall.interfaces.${cfg.bridgeInterface} = {
    allowedTCPPorts = [
      53 # DNS
    ];
    allowedUDPPorts = [
      53 # DNS
    ];
  };

  environment.systemPackages = [
    pkgs.bind
  ];

  services.bind = {
    enable = true;

    cacheNetworks = [
      "127.0.0.0/8"
      "::1/128"
      "${cfg.lanSubnet}.0/24"
      "2601:406:8100:91D8::/64"
    ];

    forwarders = [
      "8.8.8.8"
      "8.8.4.4"
      "1.1.1.1"
      "1.0.0.1"
      "2001:4860:4860::8888"
      "2606:4700:4700::1111"
      "2606:4700:4700::1001"
    ];

    extraConfig = ''
      statistics-channels {
        inet 127.0.0.1 port 8053 allow { 127.0.0.1; };
      };
    '';

    extraOptions = ''
      allow-recursion { 127.0.0.1; ::1; ${cfg.lanSubnet}.0/24; 2601:406:8100:91D8::/64; };
      dnssec-validation auto;
      listen-on { any; };
      listen-on-v6 { any; };
      minimal-responses yes;
      response-policy { zone "rpz.local"; };
    '';

    zones = {
      "${zoneDomain}" = {
        master = true;
        file = "/var/lib/named/${zoneDomain}.zone";
      };
      "0.0.10.in-addr.arpa" = {
        master = true;
        file = "/var/lib/named/10.0.0.rev";
      };
      "rpz.local" = {
        master = true;
        file = "/var/lib/named/rpz.local.zone";
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

      cat > /var/lib/named/${zoneDomain}.zone <<'EOF'
${forwardZoneText}
EOF

      cat > /var/lib/named/10.0.0.rev <<'EOF'
${reverseZoneText}
EOF
      cat > /var/lib/named/rpz.local.zone <<'EOF'
${rpzZoneText}
EOF

      chown named:named /var/lib/named/rpz.local.zone
      chmod 0640 /var/lib/named/rpz.local.zone

      chown named:named /var/lib/named/${zoneDomain}.zone /var/lib/named/10.0.0.rev
      chmod 0640 /var/lib/named/${zoneDomain}.zone /var/lib/named/10.0.0.rev

      ${pkgs.bind}/bin/named-checkzone ${zoneDomain} /var/lib/named/${zoneDomain}.zone
      ${pkgs.bind}/bin/named-checkzone 0.0.10.in-addr.arpa /var/lib/named/10.0.0.rev

      ${pkgs.bind}/bin/named-checkzone rpz.local /var/lib/named/rpz.local.zone
    '';
  };

  services.kresd.enable = lib.mkForce false;
  services.kresd.instances = 0;
}