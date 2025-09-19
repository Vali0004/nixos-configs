{ config, pkgs, ... }:

let
  my_keys = import ./ssh_keys_personal.nix;
  cfg = pkgs.writeText "configuration.nix" ''
    assert builtins.trace "Hey dumbass, wrong machine." false;
    {}
  '';
in {
  boot = {
    loader.grub.enable = true;
    # My root password is very fucking long, and uh, when it kabooms, recovering fucking SUCKS
    # So enable ssh and networking long before anything else, for my sanity
    initrd.network = {
      enable = true;
      ssh.enable = true;
      ssh.hostKeys = [ "/etc/ssh/ssh_host_ed25519_key" ];
      ssh.authorizedKeys = my_keys;
    };
  };

  networking.extraHosts = ''
    10.0.0.31 lenovo
    10.0.0.124 chromeshit
    10.0.0.201 nixos-amd
    10.0.0.244 shitzen-nixos
    74.208.44.130 router-vps
  '';

  environment.shellAliases = {
    l = null;
    ll = null;
    lss = "ls --color -lha";
  };

  i18n.defaultLocale = "en_US.UTF-8";

  nix.nixPath = [
    "nixos-config=${cfg}"
    "nixpkgs=/run/current-system/nixpkgs"
  ];

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
    vnstat.enable = true;
  };

  systemd.services.nix-daemon.serviceConfig.OOMScoreAdjust = "350";

  system.extraSystemBuilderCmds = ''
    ln -sv ${pkgs.path} $out/nixpkgs
  '';

  time.timeZone = "America/Detroit";

  users.users = let
    common_keys = import ./ssh_keys.nix;
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
