{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Better TOP
    btop
    # cURL
    curl
    # Domain Name System Utilities
    dnsutils
    # Ext4 FS
    e2fsprogs
    # GPT FDisk
    gptfdisk
    # Internet performance tool
    iperf
    # SSL Client
    openssl
    # Nano
    nano
    # Parted
    parted
    # Stack Trace
    strace
    # WebGet
    wget
  ];
}
