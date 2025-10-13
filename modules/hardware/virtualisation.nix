{ config, lib, pkgs, ... }:

{
  options.hardware = {
    virtualisation = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to Virtualization Support.";
      };
    };
  };

  config = lib.mkIf config.hardware.virtualisation.enable {
    programs.virt-manager.enable = true;

    users.groups.libvirtd.members = [
      "vali"
    ];

    virtualisation.libvirtd = {
      enable = true;
      onBoot = "ignore";
      onShutdown = "shutdown";
      qemu = {
        ovmf.enable = true;
        ovmf.packages = [ pkgs.OVMFFull.fd ];
        package = pkgs.qemu_kvm;
        runAsRoot = false;
      };
    };

    virtualisation.spiceUSBRedirection.enable = true;
  };
}
