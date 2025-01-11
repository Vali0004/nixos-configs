{ pkgs }:

{
  "mods/fabric-api.jar" = pkgs.fetchurl rec {
    hash = "sha256-TATNEpMOzG19eCI5NDhdYonSpkRLzH3q9T49o3kgHC0=";
    pname = "fabric-api";
    url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/5tj7y3PJ/${pname}-${version}.jar";
    version = "0.114.0%2B1.21.4";
  };
  "mods/ferritecore.jar" = pkgs.fetchurl rec {
    hash = "sha256-DdXpIDVSAk445zoPW0aoLrZvAxiyMonGhCsmhmMnSnk=";
    pname = "ferritecore";
    url = "https://cdn.modrinth.com/data/uXXizFIs/versions/IPM0JlHd/${pname}-${version}.jar";
    version = "7.1.1-fabric";
  };
  "mods/lithium.jar" = pkgs.fetchurl rec {
    hash = "sha256-LJFVhw/3MnsPnYTHVZbM3xJtne1lV5twuYeqZSMZEn4=";
    pname = "lithium";
    url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/t1FlWYl9/${pname}-${version}.jar";
    version = "fabric-0.14.3%2Bmc1.21.4";
  };
  "mods/modernfix.jar" = pkgs.fetchurl rec {
    hash = "sha256-yDjUaCH3wW/e5ccG4tpeO4JkMJScj8EbDSvQTlLVu+s=";
    pname = "modernfix";
    url = "https://cdn.modrinth.com/data/nmDcB62a/versions/gx7PIV8n/${pname}-${version}.jar";
    version = "fabric-5.20.1%2Bmc1.21.4";
  };
  "mods/memoryleakfix.jar" = pkgs.fetchurl rec {
    hash = "sha256-uKwz1yYuAZcQ3SXkVBFmFrye0fcU7ZEFlLKKTB2lrd4=";
    pname = "memoryleakfix";
    url = "https://cdn.modrinth.com/data/NRjRiSSD/versions/5xvCCRjJ/${pname}-${version}.jar";
    version = "fabric-1.17%2B-1.1.5";
  };
  "mods/Debugify.jar" = pkgs.fetchurl rec {
    hash = "sha256-9f1/iLjcor5vkWoHjiRggP8zhTc3fY80d6hJZeb9OeU=";
    pname = "Debugify";
    url = "https://cdn.modrinth.com/data/QwxR6Gcd/versions/TxwUizo2/${pname}-${version}.jar";
    version = "1.21.4%2B1.0";
  };
}