{
  nix = {
    optimise = {
      automatic = true;
      persistent = true;
    };
    settings = {
      download-buffer-size = 524288000;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      substituters = [
        "https://nix-community.cachix.org"
        #"https://hydra.lab004.dev"
      ];
      trusted-users = [
        "vali"
        "@wheel"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        #"hydra.lab004.dev:6+mPv9GwAFx/9J+mIL0I41pU8k4HX0KiGi1LUHJf7LY="
      ];
    };
  };

  nixpkgs = {
    config.allowUnfree = true;
    hostPlatform = "x86_64-linux";
  };

  system.stateVersion = "25.11";

  systemd.services.nix-daemon.serviceConfig.OOMScoreAdjust = "350";
}