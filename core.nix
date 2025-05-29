{ config, pkgs, ... }:

let
  common_keys = import ./ssh_keys.nix;
  my_keys = import ./ssh_keys_personal.nix;
in {
  # Use the GRUB 2 boot loader.
  boot.loader = {
    grub = {
      enable = true;
    };
  };

  environment = {
    shellAliases = {
      l = null;
      ll = null;
      lss = "ls --color -lha";
    };
  };

  time.timeZone = "America/Detroit";

  i18n.defaultLocale = "en_US.UTF-8";

  services = {
    fail2ban = {
      enable = true;
      maxretry = 5;
      ignoreIP = [
        # Whitelist some subnets
        "10.0.127.0/8" "172.16.0.0/12" "192.168.0.0/16"
        "8.8.8.8"
      ];
      bantime = "24h"; # Ban IPs for one day on the first ban
      bantime-increment = {
        enable = true; # Enable increment of bantime after each violation
        formula = "ban.Time * math.exp(float(ban.Count+1)*banFactor)/math.exp(1*banFactor)";
        maxtime = "168h"; # Do not ban for more than 1 week
        overalljails = true; # Calculate the bantime based on all the violations
      };
    };
    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };
    toxvpn = {
      enable = true;
      auto_add_peers = [
        "e0f6bcec21be59c77cf338e3946a766cd17a8e9c40a2b7fe036e7996f3a59554b4ecafdc2df6" # chromeshit
        "dd51f5f444b63c9c6d58ecf0637ce4c161fe776c86dc717b2e209bc686e56a5d2227dfee1338" # clever
      ];
    };
    vnstat.enable = true;
  };

  systemd.services.toxvpn.serviceConfig.TimeoutStartSec = "infinity";

  users.users = with common_keys; with my_keys; {
    root = {
      openssh.authorizedKeys.keys = my_keys ++ common_keys;
    };
    vali = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "ipfs"
      ];
      openssh.authorizedKeys.keys = my_keys ++ common_keys;
    };
  };
}
