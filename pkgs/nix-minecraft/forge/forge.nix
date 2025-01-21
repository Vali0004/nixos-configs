 { lib, runCommand, version, fetchurl, openjdk, jdk8, jdk11 }:

let
  # There has to be a better way to do this...
  forgeVersions = {
    "1.7.10-10.13.4.1614-1.7.10" = {
      src = fetchurl {
        url = "https://maven.minecraftforge.net/net/minecraftforge/forge/1.7.10-10.13.4.1614-1.7.10/forge-1.7.10-10.13.4.1614-1.7.10-installer.jar";
        hash = "sha256-pdYHV9izBZOSM6lC1Ql/p4gW0RbvkILAMGb+Zp4BDH8=";
      };
      offlineHash = "sha256-a5QuodkvjVhQT3r8e44RCWDhTEmR23KcOuwr+Cau8ok=";
      jarAppend = "-universial.jar";
      jdk = jdk8;
    };
    "1.16.5-36.2.42" = {
      src = fetchurl {
        url = "https://maven.minecraftforge.net/net/minecraftforge/forge/1.16.5-36.2.42/forge-1.16.5-36.2.42-installer.jar";
        hash = "sha256-36kMaB8wviQGVItkKbzLaNla9PZKsZuMWPYSj9UP+Fc=";
      };
      offlineHash = "sha256-dmHB8KsVLXjIjgd97R9R0x6ZBxt3pADV2ERbWio8Gww=";
      jarAppend = ".jar";
      jdk = jdk11;
    };
  };
  forge = forgeVersions.${version};
  offline = runCommand "forge-offline" {
    outputHash = forge.offlineHash or lib.fakeHash;
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    nativeBuildInputs = [ openjdk ];
  } ''
    mkdir -p $out
    cd $out

    cp -v ${forge.src} forge-installer.jar
    java -jar forge-installer.jar --installServer

    rm forge-installer.jar.log
  '';
in
 runCommand "forge" {
 } ''
  mkdir -pv $out/bin
  cat <<EOF > $out/bin/$name
  #!/bin/sh

  export PATH=${lib.makeBinPath [ forge.jdk ]}:\$PATH

  exec java "\$@" -jar ${offline}/forge-${version}${forge.jarAppend} nogui
  EOF
  chmod +x $out/bin/$name
  patchShebangs $out/bin
 ''
