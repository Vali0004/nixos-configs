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
        "https://hydra.lab004.dev"
      ];
      trusted-users = [
        "vali"
        "@wheel"
      ];
      trusted-public-keys = [
        "hydra.lab004.dev:6+mPv9GwAFx/9J+mIL0I41pU8k4HX0KiGi1LUHJf7LY="
      ];
    };
  };

  nixpkgs = {
    config.allowUnfree = true;
    hostPlatform = "x86_64-linux";
  };

  system.stateVersion = "26.11";

  systemd.services.nix-daemon.serviceConfig.OOMScoreAdjust = "350";
}