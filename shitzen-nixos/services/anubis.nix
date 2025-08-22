{ config, inputs, lib, pkgs, ... }:

{
  services.anubis = {
    instances."hydra-server" = {
      settings = {
        TARGET = "http://127.0.0.1:3001";
        BIND = ":3002";
        BIND_NETWORK = "tcp";
        METRICS_BIND = ":9001";
        METRICS_BIND_NETWORK = "tcp";
      };
    };
  };
}