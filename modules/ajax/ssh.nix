{
  programs.ssh.extraConfig = ''
    Host LA-01-OVPN
      Hostname LA-01-OVPN
      User root

    Host UK-01-OVPN
      Hostname UK-01-OVPN
      User root

    Host Sweden-01-OVPN
      Hostname Sweden-01-OVPN
      User root

    Host Amsterdam-01-OVPN
      Hostname Amsterdam-01-OVPN
      User root

    Host Japan-01-OVPN
      Hostname Japan-01-OVPN
      User root

    Host France-01-OVPN
      Hostname France-01-OVPN
      User root

    Host Toronto-01-OVPN
      Hostname Toronto-01-OVPN
      User root

    Host PRV-Germany-01
      Hostname PRV-Germany-01
      User root
      Port 5192

    Host AU-Syndey-01-OVH-WG
      Hostname AU-Syndey-01-OVH-WG
      User root
      Port 1731

    Host BHS-02-OVH-WG
      Hostname BHS-02-OVH-WG
      User root
      Port 9289

    Host LZ-AMS-02-OVH-WG
      Hostname LZ-AMS-02-OVH-WG
      User root
      Port 6934

    Host RBX-01-OVH-WG
      Hostname RBX-01-OVH-WG
      User root
      Port 5296

    Host UK-London-02-OVH-WG
      Hostname UK-London-02-OVH-WG
      User root
      Port 3952

    Host US-Atlana-GA-01-OVH-WG
      Hostname US-Atlana-GA-01-OVH-WG
      User root
      Port 9409

    Host US-Chicago-IL-02-OVH-WG
      Hostname US-Chicago-IL-02-OVH-WG
      User root
      Port 1703

    Host US-Chicago-IL-03-OVH-WG
      Hostname US-Chicago-IL-03-OVH-WG
      User root
      Port 6432

    Host US-Dallas-TX-01-OVH-WG
      Hostname US-Dallas-TX-01-OVH-WG
      User root
      Port 6042

    Host US-LosAngeles-CA-02-OVH-WG
      Hostname US-LosAngeles-CA-02-OVH-WG
      User root
      Port 5903

    Host US-Miami-Florda-01-OVH-WG
      Hostname US-Miami-Florda-01-OVH-WG
      User root
      Port 5903

    Host US-NYC-NY-01-OVH-WG
      Hostname US-NYC-NY-01-OVH-WG
      User root
      Port 5903

    Host US-Phoenix-AZ-01-OVH-WG
      Hostname US-Phoenix-AZ-01-OVH-WG
      User root
      Port 5903

    Host US-Chicago-IL-04-Hosturly-WG
      Hostname US-Chicago-IL-04-Hosturly-WG
      User root
      Port 5903
  '';
}