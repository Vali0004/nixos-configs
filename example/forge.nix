 { lib, runCommand, version, fetchurl, openjdk, jdk8 }:

let
  forge_versions = {
    "1.16.5-36.2.42" = {
      src = fetchurl {
        url = "https://maven.minecraftforge.net/net/minecraftforge/forge/1.16.5-36.2.42/forge-1.16.5-36.2.42-installer.jar";
        hash = "sha256-36kMaB8wviQGVItkKbzLaNla9PZKsZuMWPYSj9UP+Fc=";
      };
      offlinehash = "sha256-NJWqKxZPRO5XSfCf8BiuEOmJW+FNd5+pG707PBlkIfA=";
      offlineFlag = "--makeOffline";
      serverjar = "server.jar";
    };
    "1.7.10-10.13.4.1614" = {
      src = fetchurl {
        url = "https://maven.minecraftforge.net/net/minecraftforge/forge/1.7.10-10.13.4.1614-1.7.10/forge-1.7.10-10.13.4.1614-1.7.10-installer.jar";
        hash = "sha256-pdYHV9izBZOSM6lC1Ql/p4gW0RbvkILAMGb+Zp4BDH8=";
      };
      offlinehash = "sha256-a5QuodkvjVhQT3r8e44RCWDhTEmR23KcOuwr+Cau8ok=";
      offlineFlag = "--installServer";
      #serverjar = "minecraft_server.1.7.10.jar";
      serverjar = "forge-1.7.10-10.13.4.1614-1.7.10-universal.jar";
      jdk = jdk8;
    };
  };
  forge = forge_versions.${version};
  offline = runCommand "forge-offline" {
    outputHash = forge.offlinehash or lib.fakeHash;
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    nativeBuildInputs = [ openjdk ];
  } ''
    mkdir -p $out
    cd $out

    cp -v ${forge.src} forge-installer.jar
    java -jar forge-installer.jar ${forge.offlineFlag}

    rm forge-installer.jar.log
  '';
in
 runCommand "forge" {
 } ''
  mkdir -pv $out/bin
  cat <<EOF > $out/bin/$name
  #!/bin/sh

  export PATH=${lib.makeBinPath [ forge.jdk ]}:\$PATH

  exec java "\$@" -jar ${offline}/${forge.serverjar} nogui
  EOF
  chmod +x $out/bin/$name
  patchShebangs $out/bin
 ''
