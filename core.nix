{ pkgs, ... }:

{
  # Use the GRUB 2 boot loader.
  boot.loader = {
    grub = {
      enable = true;
    };
  };

  environment = {
    shellAliases = {
      l = null;
      ll = null;
      lss = "ls --color -lha";
    };
  };

  time.timeZone = "America/Detroit";

  i18n.defaultLocale = "en_US.UTF-8";

  services = {
    fail2ban = {
      enable = true;
      maxretry = 5;
      ignoreIP = [
        # Whitelist some subnets
        "10.0.127.0/8" "172.16.0.0/12" "192.168.0.0/16"
        "8.8.8.8"
      ];
      bantime = "24h"; # Ban IPs for one day on the first ban
      bantime-increment = {
        enable = true; # Enable increment of bantime after each violation
        formula = "ban.Time * math.exp(float(ban.Count+1)*banFactor)/math.exp(1*banFactor)";
        maxtime = "168h"; # Do not ban for more than 1 week
        overalljails = true; # Calculate the bantime based on all the violations
      };
    };
    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };
    toxvpn = {
      enable = true;
      auto_add_peers = [
        "e0f6bcec21be59c77cf338e3946a766cd17a8e9c40a2b7fe036e7996f3a59554b4ecafdc2df6"
        "dd51f5f444b63c9c6d58ecf0637ce4c161fe776c86dc717b2e209bc686e56a5d2227dfee1338"
      ];
    };
    vnstat.enable = true;
  };

  systemd.services.toxvpn.serviceConfig.TimeoutStartSec = "infinity";

  users.users = let
    common_keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCx1m4IonXyWTFas/gMwez2lT1hLxhE97JfcW9KWQrM6FsLlYGoZydj/C+J35Pbc1CFoBfzXUvbeglLoy7+ycpgXub0UOBh7Lk0p+jNzbSKec4gQL9SNu0vZY/pONZ0yAhEM+wEgtcjYuWRjMDUBfeiO7FOdGtbCdTT//tA3GwQ0wHWdSCPWELoaeIia3uW0w/l7a5zczLpisncvSmXnTG3qwcwbHYpYnfTkyneTTjbEZGtEWIYFub4IBuQsQqEtaDoBVGbbuB+Bm5ulksd8+FbBXKUHoswwABGb4czTUZFIZ4OeXe79hRG/hPeO5AzFLOlhDg8t1/MCqOio4gzYjC7Bz1WJND8zg1Q7vfAJp0Sq0sMS9WvlTmVM0egECdEXhLP/p0a0GBES1T/005HG8yE9sKQi8R0ZaFMhxL5IY3jlc/BOt3jdmeAHUaJBgZqbLN0QJMGkhikgzVTzGjkRHSQgbrH7RKfDQ+CAwVRL+RiDmL9ZorbgdxW/Cr17YJ2jrMXtq/OPC33Jk+rF6UTo5cgb0HuwX4j0gqWFhiQzxoJzQNpgcFaUMFQVrvS2lOOVxFdZKDuI2hDqeD59DQq5HljdHnOb1n+5+V6kNdMTm+5JXVrSUOEdlgx/CB0BjpXeAQVdLH6p7b6kmBiJox3I05W8Go7JhNPj3Pkj15Csqujsw== vali@DESKTOP-MQBIMLL"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC34wZQFEOGkA5b0Z6maE3aKy/ix1MiK1D0Qmg4E9skAA57yKtWYzjA23r5OCF4Nhlj1CuYd6P1sEI/fMnxf+KkqqgW3ZoZ0+pQu4Bd8Ymi3OkkQX9kiq2coD3AFI6JytC6uBi6FaZQT5fG59DbXhxO5YpZlym8ps1obyCBX0hyKntD18RgHNaNM+jkQOhQ5OoxKsBEobxQOEdjIowl2QeEHb99n45sFr53NFqk3UCz0Y7ZMf1hSFQPuuEC/wExzBBJ1Wl7E1LlNA4p9O3qJUSadGZS4e5nSLqMnbQWv2icQS/7J8IwY0M8r1MsL8mdnlXHUofPlG1r4mtovQ2myzOx clever@nixos"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDzpuTz2l4ceA6dQWjPPkchi0zE159VTUrgt4+RjsHii0rhDNhjPFPx7NyUE4JXbg62R5sv2kwb7wGWS/s+Hw6Uu0QvHZoCMc5uVwXOnmggKXKhTxeHZ/igCnH8BKQ88O80KTqTpbPNm7ge0TT2fwFguaNGMtp8Ku7Mzrp4CaNPEdQMQe5sN0NyBlg3wx4eWmBbE0vsk6NVPwzWH10mZcuoXD1EWrPZfAVbk5TIbloKPsE0fzqoYYcd2NrxhdDOMGXw0lL8yTFFzjyOqqAAKexYLxRBMqYBdMLupfpOOBr7KZDNzdhPllh2sfcHmchZfIGvaSZW84e4L16/eIDRohqZn43iViKT6HHIavyB5t/wP4+FIp3lvYRrzN4BgSAs7S/tI+fNOGe8p4/zc1wKt1/hvPzvhrCs8mvGJgnxDV9/7iSmVfF55hVgUpwA9qmYesBrh4vV0xY6CYsOVndJ0ks7quQBlSbZXX4MorMy7h1pD6roTOyg3H/jNCnTsRxLQrc= vali@DESKTOP-JC0OJ0Q"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDJR3qDc8r2kbg6Q+A0dk7E6fC/wdlySBKb8X+8XgRGJg6huXaCTPZbAyvzt1IvxY69IdBymExjUie7YuFOLOKi5wisfw6d1yVjrhaoZWvXTz6eyF0ssAzM1BbqJsHU2dahQnNo7ThUguR365woBaw1UrZHEjlAiX16NxDVEyaXNImDjlQKBiAyDaa/pOCe1GUYwPgXHJMwF+6JbY+pGYAm6AvvsnjhLO0kyzwv1hSOd4qlzSobkDE9FQMbJD7uV+D1cXAv2ERdf/h9/L5dUcOEUscES+wg8ezLOhaBmq8TT9K3gmhMa47zNQU1WUAg39n+2+/Dwix0j7GNsNZdbp6B vali@nixos-amd"
    ];
  in {
    root = {
      openssh.authorizedKeys.keys = common_keys;
    };
    vali = {
      isNormalUser = true;
      extraGroups = [ "wheel" "ipfs" ]; # Enable 'sudo' for the user.
      packages = with pkgs; [
        tree
      ];
      openssh.authorizedKeys.keys = common_keys;
    };
  };
}
