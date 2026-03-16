{ config
, ... }:

{
  services = {
    samba = {
      enable = true;
      openFirewall = true;
      settings = {
        global = {
          "ea support" = "yes";
          "follow symlinks" = "yes";
          "guest account" = "nobody";
          "inherit permissions" = "yes";
          "log level" = "3";
          "map acl inherit" = "yes";
          "map to guest" = "bad user";
          "netbios name" = config.networking.hostName;
          security = "user";
          "server min protocol" = "SMB2_02";
          "server role" = "standalone server";
          "server signing" = "default";
          "server string" = config.networking.hostName;
          workgroup = "WORKGROUP";
          "vfs objects" = "acl_xattr";
        };
        data = {
          path = "/data";
          browseable = "yes";
          "read only" = "no";
          writeable = "yes";
          locking = "yes";
          "inherit permissions" = "yes";
          "directory mask" = "0775";
          "create mask" = "0664";
          "guest ok" = "no";
          "valid users" = "@users";
          "vfs objects" = "acl_xattr catia fruit streams_xattr";
          "ea support" = "yes";
          # fruit needs streams_xattr for Apple client compat.
          "fruit:metadata" = "stream";
          "fruit:resource" = "stream";
          "fruit:aapl" = "yes";
        };
      };
    };
    samba-wsdd = {
      enable = true;
      openFirewall = true;
    };
  };
}