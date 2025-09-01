{ config, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [ 6667 6697 ];

  services.inspircd = {
    enable = true;
    config = ''
      <define name="networkDomain" value="fuckk.lol">
      <define name="networkName" value="fuckkNet">

      <server
        name="irc.&networkDomain;"
        description="&networkName; IRC server"
        network="&networkName;">

      <admin
        name="Vali"
        description="Server admin"
        email="vali@&networkDomain;">

      <bind address="" port="6697" type="clients" sslprofile="gnutls">
      <bind address="" port="6667" type="clients">

      <sslprofile name="gnutls"
        keyfile="/var/lib/acme/irc.fuckk.lol/key.pem"
        certfile="/var/lib/acme/irc.fuckk.lol/fullchain.pem">

      <files motd="/etc/inspircd/motd.txt">

      <class name="Admins" commands="*" privs="*" maxchans="50">
      <type name="NetAdmin" classes="Admins" vhost="irc.&networkDomain;">

      <oper
        name="admin"
        password="$2b$05$oaq0mFrk2gASO6YI4m.DJOAYcVd0Y5zH2sRafkXNvMmLUg7mWqwrW"
        hash="bcrypt"
        host="*@*"
        type="NetAdmin">

      <connect name="main" allow="*" maxchans="20" timeout="20" pingfreq="2m" limit="5000">

      <performance netbuffersize="10240" somaxconn="128">
      <options defaultmodes="not" prefixquit="Quit: " announcets="yes">

      <module name="ssl_gnutls">
      <module name="opermodes">
      <module name="services_account">
      <module name="account">
    '';
  };

  security.acme.certs."irc.fuckk.lol" = {
    group = "inspircd";
    webroot = "/var/lib/acme/acme-challenge";
  };

  users.users.inspircd = {
    isSystemUser = true;
    group = "inspircd";
  };

  users.groups.inspircd = {};

  environment.etc."inspircd/motd.txt".text = ''
    The schizo made me do it.
  '';
}