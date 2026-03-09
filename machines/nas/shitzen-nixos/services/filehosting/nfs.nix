{ config, inputs, lib, pkgs, ... }:

let
  statd-port = 4000;
  lockd-port = 4001;
  mountd-port = 4002;
  kdc-port = 88;
  kdc-secondary-port = 750;
  kdc-passwd = 464;
  kdc-admin = 749;
in {
  networking.firewall = {
    allowedTCPPorts = [
      111 # NFS Portmapper
      2049 # NFS Traffic
      statd-port
      lockd-port
      mountd-port
      kdc-port
      kdc-secondary-port
      kdc-passwd
    ];
    allowedUDPPorts = [
      2049 # NFS Traffic
      kdc-port
      kdc-secondary-port
    ];
  };

  services.nfs.server = {
    enable = true;
    statdPort = statd-port;
    lockdPort = lockd-port;
    mountdPort = mountd-port;
    exports = ''
      /data 10.0.0.0/24(rw,async,no_subtree_check,sec=sys) cleverca22(rw,sync,no_subtree_check,sec=krb5p)
    '';
  };

  services.kerberos_server = {
    enable = true;
    settings = {
      kdcdefaults = {
        kdc_ports = "${toString kdc-port},${toString kdc-secondary-port}";
        kdc_tcp_ports = "${toString kdc-port},${toString kdc-secondary-port}";
      };
      realms = {
        "NFS.FUCKK.LOL" = {
          kadmind_port = 749;
          database_name = "/var/lib/krb5kdc/principal";
          key_stash_file = "/var/lib/krb5kdc/.k5.NFS.FUCKK.LOL";
          admin_keytab = "/etc/krb5kdc/kadm5.keytab";
          acl_file = "/etc/krb5kdc/kadm5.acl";
          max_life = "12h 0m 0s";
          max_renewable_life = "7d 0h 0m 0s";
          master_key_type = "aes256-cts-hmac-sha1-96";
          supported_enctypes = "aes256-cts-hmac-sha1-96:normal aes128-cts-hmac-sha1-96:normal";
          default_principal_flags = "RENEWABLE,FORWARDABLE";
        };
      };
    };
  };

  # Enable kerberos
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
          admin_server = "shitzen-nixos:749";
          kdc = [
            "shitzen-nixos:${toString kdc-port}"
          ];
        };
      };
    };
  };
}