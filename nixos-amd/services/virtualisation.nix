{ config, lib, pkgs, ... }:

{
  programs.virt-manager.enable = true;
  users.groups.libvirtd.members = [
    "vali"
  ];
  virtualisation = {
    libvirtd = {
      enable = true;
      onBoot = "ignore";
      onShutdown = "shutdown";
      qemu = {
        ovmf.enable = true;
        ovmf.packages = with pkgs; [
          OVMFFull.fd
        ];
        package = pkgs.qemu_kvm;
        runAsRoot = false;
      };
    };
    spiceUSBRedirection.enable = true;
  };
}
