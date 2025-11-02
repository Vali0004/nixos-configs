{ inputs
, config
, lib
, pkgs
, ... }:

{
  imports = [
    home-manager/home.nix
    #services/windowManager/dwm.nix
    services/windowManager/mango.nix
    services/displayManager.nix
    #services/picom.nix
    ./pkgs.nix
  ];

  fonts.packages = [ pkgs.nerd-fonts.dejavu-sans-mono ];

  gtk.enable = true;

  hardware = {
    amd.enable = true;
    amdgpu.enable = false;
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    audio.pipewire.enable = true;
    bluetooth.enable = false;
  };

  networking = {
    hostName = "nixos-testing-vm";
    useDHCP = true;
    usePredictableInterfaceNames = false;
  };

  programs = {
    command-not-found.enable = true;
    dconf.enable = true;
    git = {
      enable = true;
      lfs.enable = true;
    };
    google-chrome.enable = true;
    nemo.enable = true;
    zsh.enable = true;
  };

  qt.enable = true;

  security = {
    # Fucking realtime priority
    rtkit.enable = lib.mkForce false;
    sudo.enable = true;
  };

  services = {
    xserver = {
      enable = false;
      # Disable XTerm
      excludePackages = [ pkgs.xterm ];
      desktopManager.xterm.enable = false;
    };
    openssh.enable = true;
    qemuGuest.enable = true;
  };

  system.stateVersion = "25.11";

  systemd.settings.Manager.RebootWatchdogSec = "0";

  users.users.vali = {
    isNormalUser = true;
    extraGroups = [
      "corectrl"
      "input"
      "render"
      "tty"
      "video"
      "wheel"
    ];
    initialPassword = "773415";
    useDefaultShell = false;
    shell = pkgs.zsh;
  };

  xdg.enable = true;

  virtualisation.vmVariant = {
    virtualisation = {
      cores = 4;
      diskSize = 32 * 1024;
      memorySize = 8192;
      forwardPorts = [
        {
          from = "host";
          host.port = 2222;
          guest.port = 22;
        }
      ];
      qemu.options = [
        "-enable-kvm"
        "-cpu" "host"
        "-device" "virtio-vga-gl"
        "-display" "gtk,gl=on"
      ];
    };
  };
}