{ ... }:

let
  kdc-port = 88;
  kdc-admin-port = 749;
in {
  security.krb5 = {
    enable = true;
    settings = {
      domain_realm."fuckk.lol" = "NFS.FUCKK.LOL";
      libdefaults = {
        default_realm = "NFS.FUCKK.LOL";
      };
      logging = {
        admin_server = "SYSLOG:NOTICE";
        default = "SYSLOG:NOTICE";
        kdc = "SYSLOG:NOTICE";
      };
      realms = {
        "NFS.FUCKK.LOL" = {
          admin_server = "shitzen-nixos:${toString kdc-admin-port}";
          kdc = [
            "shitzen-nixos:${toString kdc-port}"
          ];
        };
      };
    };
  };
}