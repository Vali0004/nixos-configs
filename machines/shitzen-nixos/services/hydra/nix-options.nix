{ config
, pkgs
, ... }:

{
  nix = {
    buildMachines = [
      # TODO: Make this a module
      {
        hostName = config.networking.hostName;
        protocol = null;
        systems = [ "i686-linux" "x86_64-linux" ];
        supportedFeatures = [ "kvm" "nixos-test" "big-parallel" "benchmark" ];
        maxJobs = 4;
      }
    ];
    extraOptions = ''
      allowed-uris = https://github.com https://api.github.com https://codeload.github.com https://raw.githubusercontent.com https://github.com/nixos github:
      experimental-features = nix-command flakes
    '';
    gc = {
      automatic = true;
      dates = "0:00:00";
      options = ''--max-freed "$((32 * 1024**3 - 1024 * $(df -P -k /nix/store | tail -n 1 | ${pkgs.gawk}/bin/awk '{ print $4 }')))"'';
    };
    settings.auto-optimise-store = true;
  };

  environment.etc."nix/netrc" = {
    user = "hydra";
    source = config.age.secrets.nix-netrc.path;
  };
}