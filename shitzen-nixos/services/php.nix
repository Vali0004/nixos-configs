{ config, pkgs, lib, ... }:

let
  app = "php-fpm";
  php-env = pkgs.php.buildEnv {
    extensions = { enabled, all }: with all; enabled ++ [
      memcached redis mbstring bcmath mysqli curl zip gd
    ];
    extraConfig = ''
      memory_limit = 256M
    '';
  };
in {
  services.phpfpm.pools.${app} = {
    user = "nginx";
    group = "nginx";
    settings = {
      "listen.owner" = config.services.nginx.user;
      "pm" = "dynamic";
      "pm.max_children" = 5;
      "pm.start_servers" = 2;
      "pm.min_spare_servers" = 1;
      "pm.max_spare_servers" = 3;
      "pm.max_requests" = 500;
    };
    phpEnv."PATH" = lib.makeBinPath [ php-env ];
    phpPackage = php-env;
  };
}