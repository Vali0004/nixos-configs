{ config
, ... }:

{
  networking.nat.forwardPorts = [
    {
      destination = "10.0.0.6:22";
      proto = "tcp";
      sourcePort = 22;
    }
    {
      destination = "10.0.0.7:80";
      proto = "tcp";
      sourcePort = 80;
    }
  ];
}