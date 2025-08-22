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
    toxvpn = {
      enable = true;
      auto_add_peers = [
        "e0f6bcec21be59c77cf338e3946a766cd17a8e9c40a2b7fe036e7996f3a59554b4ecafdc2df6" # chromeshit
        "dd51f5f444b63c9c6d58ecf0637ce4c161fe776c86dc717b2e209bc686e56a5d2227dfee1338" # clever
      ];
    };
    vnstat.enable = true;
  };

  systemd.services = {
    nix-daemon.serviceConfig.OOMScoreAdjust = "350";
    toxvpn.serviceConfig.TimeoutStartSec = "infinity";
  };

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
