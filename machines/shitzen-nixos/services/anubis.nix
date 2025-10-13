{ config, inputs, lib, pkgs, ... }:

{
  services.anubis = {
    instances."hydra-server" = {
      settings = {
        TARGET = "http://192.168.100.1:3001";
        BIND = ":3002";
        BIND_NETWORK = "tcp";
        METRICS_BIND = ":9002";
        METRICS_BIND_NETWORK = "tcp";
      };
    };
  };
}