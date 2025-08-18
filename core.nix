{ config, pkgs, ... }:

{
  boot.loader.grub.enable = true;

  environment.shellAliases = {
    l = null;
    ll = null;
    lss = "ls --color -lha";
  };

  time.timeZone = "America/Detroit";

  i18n.defaultLocale = "en_US.UTF-8";

  services = {
    fail2ban = {
      enable = true;
      maxretry = 5;
      ignoreIP = [
        "10.0.0.0/24"
        "10.0.127.0/24"
      ];
      bantime = "24h";
      bantime-increment = {
        enable = true;
        formula = "ban.Time * math.exp(float(ban.Count+1)*banFactor)/math.exp(1*banFactor)";
        maxtime = "168h"; # 1 week
        overalljails = true;
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
        "6ebba680e6e85e5c5a29209d30be6403bb1bfcf623d8c71da719c6a7c1ce8e52740d1668b1e9" # unison
        "332d4d3dd80e8442ce95b59c31492c8d7acbbf08d0105619aadd54c9328628108d964fec21a3" # unison laptop
      ];
    };
    vnstat.enable = true;
  };

  systemd.services = {
    nix-daemon.serviceConfig.OOMScoreAdjust = "350";
    toxvpn.serviceConfig.TimeoutStartSec = "infinity";
  };

  users.users = let
    common_keys = import ./ssh_keys.nix;
    my_keys = import ./ssh_keys_personal.nix;
  in {
    root = {
      openssh.authorizedKeys.keys = my_keys ++ common_keys;
    };
    vali = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = my_keys ++ common_keys;
    };
  };
}
