{ pkgs, lib, ... }:

let
  nix-minecraft = builtins.getFlake "/home/clever/apps/nix-minecraft";
  fetchMods = modfile:
  let
    modData = import modfile;
    f = { name, value }:
    {
      name = "mods/${name}";
      value = value.src or (pkgs.fetchurl {
        inherit name;
        inherit (value) url;
        hash = value.hash or lib.fakeHash;
      });
    };
  in lib.listToAttrs (map f (lib.attrsToList modData));
in {
  imports = [
    nix-minecraft.nixosModules.minecraft-servers
  ];
  networking.firewall.allowedTCPPorts = [ 25565 ];
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [ nix-minecraft.overlay ];
  services = {
    minecraft-servers = {
      dataDir = "/var/lib/minecraft";
      enable = true;
      eula = true;
      managementSystem = {
        systemd-socket.enable = true;
        tmux.enable = false;
      };
      servers = {
        foo = {
          autoStart = true;
          enable = false;
          package = pkgs.callPackage ./forge.nix { version = "1.16.5-36.2.42"; };
        };
        shiny = {
          enable = true;
          autoStart = false;
          package = pkgs.callPackage ./forge.nix { version = "1.7.10-10.13.4.1614"; };
          files = fetchMods ./shiny_mods.nix;
          serverProperties = {
            level-name = "New World";
          };
        };
      };
    };
  };
}
