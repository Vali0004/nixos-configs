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
        "hydra.lab004.dev-1:gPXVaEarmWgIFDuqmpf+9gXetBCC9jxzkZg+CZ8cC+M="
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