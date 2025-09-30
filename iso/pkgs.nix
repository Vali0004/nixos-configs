{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Better TOP
    btop
    # cURL
    curl
    # Domain Name System Utilities
    dnsutils
    # Internet performance tool
    iperf
    # SSL Client
    openssl
    # Stack Trace
    strace
    # WebGet
    wget
  ];
}
