{ config, lib, pkgs, modulesPath, ... }:

# Building:
# nix-build '<nixpkgs/nixos/release.nix>' --arg configuration ./vali.nix -A iso_minimal.x86_64-linux
{
  environment.systemPackages = with pkgs; [
    curl
    dnsutils
    git
    htop
    iperf
    openssl
    strace
    wget
  ];

  networking = {
    defaultGateway = "10.0.0.1";
    hostName = "nixos-recovery";
    interfaces.enp7s0 = {
      ipv4.addresses = [{
        address = "10.0.0.244";
        prefixLength = 24;
      }];
    };
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
    ];
    useDHCP = false;
  };

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    substituters = [
      "https://cache.nixos.org/"
    ];
    trusted-users = [
      "root"
      "@wheel"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  swapDevices = [{
    device = "/var/lib/swap1";
    size = 1024; # in mb
  }];

  users.users = let
    common_keys = [
      # Desktop (Windows WSL)
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCx1m4IonXyWTFas/gMwez2lT1hLxhE97JfcW9KWQrM6FsLlYGoZydj/C+J35Pbc1CFoBfzXUvbeglLoy7+ycpgXub0UOBh7Lk0p+jNzbSKec4gQL9SNu0vZY/pONZ0yAhEM+wEgtcjYuWRjMDUBfeiO7FOdGtbCdTT//tA3GwQ0wHWdSCPWELoaeIia3uW0w/l7a5zczLpisncvSmXnTG3qwcwbHYpYnfTkyneTTjbEZGtEWIYFub4IBuQsQqEtaDoBVGbbuB+Bm5ulksd8+FbBXKUHoswwABGb4czTUZFIZ4OeXe79hRG/hPeO5AzFLOlhDg8t1/MCqOio4gzYjC7Bz1WJND8zg1Q7vfAJp0Sq0sMS9WvlTmVM0egECdEXhLP/p0a0GBES1T/005HG8yE9sKQi8R0ZaFMhxL5IY3jlc/BOt3jdmeAHUaJBgZqbLN0QJMGkhikgzVTzGjkRHSQgbrH7RKfDQ+CAwVRL+RiDmL9ZorbgdxW/Cr17YJ2jrMXtq/OPC33Jk+rF6UTo5cgb0HuwX4j0gqWFhiQzxoJzQNpgcFaUMFQVrvS2lOOVxFdZKDuI2hDqeD59DQq5HljdHnOb1n+5+V6kNdMTm+5JXVrSUOEdlgx/CB0BjpXeAQVdLH6p7b6kmBiJox3I05W8Go7JhNPj3Pkj15Csqujsw== vali@DESKTOP-MQBIMLL"
      # Desktop (NixOS)
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDJR3qDc8r2kbg6Q+A0dk7E6fC/wdlySBKb8X+8XgRGJg6huXaCTPZbAyvzt1IvxY69IdBymExjUie7YuFOLOKi5wisfw6d1yVjrhaoZWvXTz6eyF0ssAzM1BbqJsHU2dahQnNo7ThUguR365woBaw1UrZHEjlAiX16NxDVEyaXNImDjlQKBiAyDaa/pOCe1GUYwPgXHJMwF+6JbY+pGYAm6AvvsnjhLO0kyzwv1hSOd4qlzSobkDE9FQMbJD7uV+D1cXAv2ERdf/h9/L5dUcOEUscES+wg8ezLOhaBmq8TT9K3gmhMa47zNQU1WUAg39n+2+/Dwix0j7GNsNZdbp6B vali@nixos-amd"
      # Laptop (Windows WSL)
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDzpuTz2l4ceA6dQWjPPkchi0zE159VTUrgt4+RjsHii0rhDNhjPFPx7NyUE4JXbg62R5sv2kwb7wGWS/s+Hw6Uu0QvHZoCMc5uVwXOnmggKXKhTxeHZ/igCnH8BKQ88O80KTqTpbPNm7ge0TT2fwFguaNGMtp8Ku7Mzrp4CaNPEdQMQe5sN0NyBlg3wx4eWmBbE0vsk6NVPwzWH10mZcuoXD1EWrPZfAVbk5TIbloKPsE0fzqoYYcd2NrxhdDOMGXw0lL8yTFFzjyOqqAAKexYLxRBMqYBdMLupfpOOBr7KZDNzdhPllh2sfcHmchZfIGvaSZW84e4L16/eIDRohqZn43iViKT6HHIavyB5t/wP4+FIp3lvYRrzN4BgSAs7S/tI+fNOGe8p4/zc1wKt1/hvPzvhrCs8mvGJgnxDV9/7iSmVfF55hVgUpwA9qmYesBrh4vV0xY6CYsOVndJ0ks7quQBlSbZXX4MorMy7h1pD6roTOyg3H/jNCnTsRxLQrc= vali@DESKTOP-JC0OJ0Q"
      # Clever (Desktop)
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC34wZQFEOGkA5b0Z6maE3aKy/ix1MiK1D0Qmg4E9skAA57yKtWYzjA23r5OCF4Nhlj1CuYd6P1sEI/fMnxf+KkqqgW3ZoZ0+pQu4Bd8Ymi3OkkQX9kiq2coD3AFI6JytC6uBi6FaZQT5fG59DbXhxO5YpZlym8ps1obyCBX0hyKntD18RgHNaNM+jkQOhQ5OoxKsBEobxQOEdjIowl2QeEHb99n45sFr53NFqk3UCz0Y7ZMf1hSFQPuuEC/wExzBBJ1Wl7E1LlNA4p9O3qJUSadGZS4e5nSLqMnbQWv2icQS/7J8IwY0M8r1MsL8mdnlXHUofPlG1r4mtovQ2myzOx clever@nixos"
      # Unison
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMcfR7F64p8vCDFgwx2QtQClL9sFDrrKX6BgufAnBM1z ethan@DESKTOP-0QH0MFO"
      # Proxy
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGoYU20wQmNyTpIPIsuL2scs9FRei9ksYjsKZeE94uDP codeine@DESKTOP-L2G494A"
    ];
  in {
    root = {
      openssh.authorizedKeys.keys = common_keys;
    };
    vali = {
      isNormalUser = true;
      extraGroups = [ "wheel" "ipfs" ];
      openssh.authorizedKeys.keys = common_keys;
    };
  };

  system.stateVersion = "25.11";
}
