{ config, lib, pkgs, ... }:

{
  imports = [
    ./kernel.nix
    ./loader.nix
    ./rescue.nix
  ];

  boot.consoleLogLevel = 0;

  boot.extraModprobeConfig = "options vfio-pci ids=1002:7340,1002:ab38";
  boot.extraModulePackages = [ ];

  boot.initrd = {
    availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
    kernelModules = [ ];
    systemd.enable = true;
    # Silence Stage 1
    verbose = false;
  };

  boot.plymouth = {
    enable = true;
    theme = "cross_hud";
    themePackages = with pkgs; [
      (adi1090x-plymouth-themes.override {
        selected_themes = [ "cross_hud" ];
      })
    ];
  };

  boot.tmp.useTmpfs = false;
}