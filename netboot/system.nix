let
  nixpkgs = builtins.getFlake "github:nixos/nixpkgs/418468ac9527e799809c900eda37cbff999199b6";

  sys = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      ({ config, pkgs, lib, modulesPath, ... }: {
        imports = [
          (modulesPath + "/installer/netboot/netboot-minimal.nix")
        ];
        config = {
          services.getty.autologinUser = lib.mkForce "root";
          users.users.root.openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDJR3qDc8r2kbg6Q+A0dk7E6fC/wdlySBKb8X+8XgRGJg6huXaCTPZbAyvzt1IvxY69IdBymExjUie7YuFOLOKi5wisfw6d1yVjrhaoZWvXTz6eyF0ssAzM1BbqJsHU2dahQnNo7ThUguR365woBaw1UrZHEjlAiX16NxDVEyaXNImDjlQKBiAyDaa/pOCe1GUYwPgXHJMwF+6JbY+pGYAm6AvvsnjhLO0kyzwv1hSOd4qlzSobkDE9FQMbJD7uV+D1cXAv2ERdf/h9/L5dUcOEUscES+wg8ezLOhaBmq8TT9K3gmhMa47zNQU1WUAg39n+2+/Dwix0j7GNsNZdbp6B vali@nixos-amd" ];

          system.stateVersion = config.system.nixos.release;
        };
      })
    ];
  };

  run-pixiecore = let
    hostPkgs = if sys.pkgs.system == builtins.currentSystem
               then sys.pkgs
               else nixpkgs.legacyPackages.${builtins.currentSystem};
    build = sys.config.system.build;
  in hostPkgs.writers.writeBash "run-pixiecore" ''
    exec ${hostPkgs.pixiecore}/bin/pixiecore \
      boot ${build.kernel}/bzImage ${build.netbootRamdisk}/initrd \
      --cmdline "init=${build.toplevel}/init loglevel=4" \
      --debug --dhcp-no-bind \
      --port 64172 --status-port 64172 "$@"
  '';
in
  run-pixiecore
