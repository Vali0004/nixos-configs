{ ... }:

{
  imports = [
    boot/boot.nix
    boot/grub.nix
    certificates/module.nix
    environment/locale.nix
    environment/shell-aliases.nix
    hardware/audio/easyEffects.nix
    hardware/audio/server.nix
    hardware/amdgpu.nix
    hardware/bluetooth.nix
    hardware/virtualisation.nix
    hardware/wifi.nix
    nix/settings.nix
    #networking/secrets-private.nix
    networking/hosts.nix
    programs/element-desktop.nix
    programs/google-chrome.nix
    programs/kde-ark.nix
    programs/nemo.nix
    programs/steam.nix
    programs/unityhub.nix
    programs/vscode.nix
    programs/zsh.nix
    zfs/module.nix
    zfs/fragmentation.nix
    ./gtk.nix
    ./qt.nix
    ./xdg.nix
  ];
}