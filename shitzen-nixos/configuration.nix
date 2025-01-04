{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    grub = {
      enable = true;
      copyKernels = true;
      device = "nodev";
      efiSupport = true;
      efiInstallAsRemovable = true;
    };
    efi.canTouchEfiVariables = false;
  };

  networking.hostName = "shitzen-nixos"; # Define your hostname.

  # Set your time zone.
  time.timeZone = "America/Detroit";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  users.users = let
    common_keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCx1m4IonXyWTFas/gMwez2lT1hLxhE97JfcW9KWQrM6FsLlYGoZydj/C+J35Pbc1CFoBfzXUvbeglLoy7+ycpgXub0UOBh7Lk0p+jNzbSKec4gQL9SNu0vZY/pONZ0yAhEM+wEgtcjYuWRjMDUBfeiO7FOdGtbCdTT//tA3GwQ0wHWdSCPWELoaeIia3uW0w/l7a5zczLpisncvSmXnTG3qwcwbHYpYnfTkyneTTjbEZGtEWIYFub4IBuQsQqEtaDoBVGbbuB+Bm5ulksd8+FbBXKUHoswwABGb4czTUZFIZ4OeXe79hRG/hPeO5AzFLOlhDg8t1/MCqOio4gzYjC7Bz1WJND8zg1Q7vfAJp0Sq0sMS9WvlTmVM0egECdEXhLP/p0a0GBES1T/005HG8yE9sKQi8R0ZaFMhxL5IY3jlc/BOt3jdmeAHUaJBgZqbLN0QJMGkhikgzVTzGjkRHSQgbrH7RKfDQ+CAwVRL+RiDmL9ZorbgdxW/Cr17YJ2jrMXtq/OPC33Jk+rF6UTo5cgb0HuwX4j0gqWFhiQzxoJzQNpgcFaUMFQVrvS2lOOVxFdZKDuI2hDqeD59DQq5HljdHnOb1n+5+V6kNdMTm+5JXVrSUOEdlgx/CB0BjpXeAQVdLH6p7b6kmBiJox3I05W8Go7JhNPj3Pkj15Csqujsw== vali@DESKTOP-MQBIMLL"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC34wZQFEOGkA5b0Z6maE3aKy/ix1MiK1D0Qmg4E9skAA57yKtWYzjA23r5OCF4Nhlj1CuYd6P1sEI/fMnxf+KkqqgW3ZoZ0+pQu4Bd8Ymi3OkkQX9kiq2coD3AFI6JytC6uBi6FaZQT5fG59DbXhxO5YpZlym8ps1obyCBX0hyKntD18RgHNaNM+jkQOhQ5OoxKsBEobxQOEdjIowl2QeEHb99n45sFr53NFqk3UCz0Y7ZMf1hSFQPuuEC/wExzBBJ1Wl7E1LlNA4p9O3qJUSadGZS4e5nSLqMnbQWv2icQS/7J8IwY0M8r1MsL8mdnlXHUofPlG1r4mtovQ2myzOx clever@nixos"
    ];
  in {
    root = {
      openssh.authorizedKeys.keys = common_keys;
    };
    vali = {
      isNormalUser = true;
      extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
      packages = with pkgs; [
        tree
      ];
      openssh.authorizedKeys.keys = common_keys;
    };
  };

  environment.systemPackages = with pkgs; [
    git
    htop
    neofetch
    openssl
    unzip
    wget
    zip
  ];

  services = {
    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };
    toxvpn = {
      enable = true;
      localip = "10.0.127.3";
      auto_add_peers = [ "ae395131cb50234bed128ff0ff5ffd495517565b1de6522f41f18a925e575c23978546982368" "e0f6bcec21be59c77cf338e3946a766cd17a8e9c40a2b7fe036e7996f3a59554b4ecafdc2df6" ];
    };
  };

  systemd.services.toxvpn.serviceConfig.TimeoutStartSec = "infinity";

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11"; # Did you read the comment?

}

