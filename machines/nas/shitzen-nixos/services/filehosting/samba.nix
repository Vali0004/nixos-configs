{
  services = {
    samba = {
      enable = true;
      openFirewall = true;
      settings = {
        global = {
          "follow symlinks" = "yes";
          "guest account" = "nobody";
          "inherit permissions" = "yes";
          "log level" = "3";
          "map to guest" = "bad user";
          "netbios name" = "shitzen-nixos";
          "security" = "user";
          "server role" = "standalone server";
          "server signing" = "disabled";
          "server string" = "shitzen-nixos";
          "workgroup" = "WORKGROUP";
        };
        data = {
          browseable = "yes";
          "create mask" = "0644";
          "create mode" = "0660";
          "directory mask" = "0770";
          "directory mode" = "0775";
          "force create mode" = "0660";
          "force directory mode" = "0775";
          "guest ok" = "no";
          locking = "no";
          path = "/data";
          "read only" = "no";
          "valid users" = "@users";
          writeable = "yes";
        };
      };
    };
    samba-wsdd = {
      enable = true;
      openFirewall = true;
    };
  };
}