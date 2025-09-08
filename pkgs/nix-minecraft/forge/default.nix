{ lib, runCommand, version, fetchurl, openjdk, openjdk_headless, jdk21_headless, jdk17_headless, jdk8_headless, jdk11_headless }:

let
  # There has to be a better way to do this...
  # Maybe a json file to define versions?
  forgeVersions = {
    "1.7.10-10.13.4.1614-1.7.10" = {
      src = fetchurl {
        url = "https://maven.minecraftforge.net/net/minecraftforge/forge/1.7.10-10.13.4.1614-1.7.10/forge-1.7.10-10.13.4.1614-1.7.10-installer.jar";
        hash = "sha256-pdYHV9izBZOSM6lC1Ql/p4gW0RbvkILAMGb+Zp4BDH8=";
      };
      javaArgs = "-jar ${offline}/forge-${version}-universial.jar";
      jdk = jdk8_headless;
      offlineHash = "sha256-a5QuodkvjVhQT3r8e44RCWDhTEmR23KcOuwr+Cau8ok=";
    };
    "1.16.5-36.2.26" = {
      src = fetchurl {
        url = "https://maven.minecraftforge.net/net/minecraftforge/forge/1.16.5-36.2.26/forge-1.16.5-36.2.26-installer.jar";
        hash = "sha256-yXVtSlcdUWqsAnTK3w18HTFX++MTkxA3Pgmx4iyEJ/s=";
      };
      javaArgs = "${offline}/forge-${version}.jar";
      jdk = jdk11_headless;
      offlineHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    };
    "1.16.5-36.2.39" = {
      src = fetchurl {
        url = "https://maven.minecraftforge.net/net/minecraftforge/forge/1.16.5-36.2.39/forge-1.16.5-36.2.39-installer.jar";
        hash = "sha256-vCO9DgxvF6ff3dvqZfAIyBJq2Pm7hLmkcGmiuo0C/M0=";
      };
      javaArgs = "${offline}/forge-${version}.jar";
      jdk = jdk11_headless;
      offlineHash = "sha256-OAgoStxooKGfxF3KHy3htkiT4kj8mTfHEPSvdN0CMR0=";
    };
    "1.16.5-36.2.42" = {
      src = fetchurl {
        url = "https://maven.minecraftforge.net/net/minecraftforge/forge/1.16.5-36.2.42/forge-1.16.5-36.2.42-installer.jar";
        hash = "sha256-36kMaB8wviQGVItkKbzLaNla9PZKsZuMWPYSj9UP+Fc=";
      };
      javaArgs = "-jar ${offline}/forge-${version}.jar";
      jdk = jdk11_headless;
      offlineHash = "sha256-XGi/hWRY2bk0+ULe1ERVAwGs9FAaPbXXCqJ1+A8aoCw=";
    };
    "1.18.2-40.3.0" = {
      src = fetchurl {
        url = "https://maven.minecraftforge.net/net/minecraftforge/forge/1.18.2-40.3.0/forge-1.18.2-40.3.0-installer.jar";
        hash = "sha256-lDTCl5BQTc0RzpfLMN2IkbSxiEiYI1e8G1q/p5+5UQM=";
      };
      javaArgs = "@libraries/net/minecraftforge/forge/${version}/unix_args.txt";
      # Should be fine to use modern jdk versions on anything past 1.16 :pray:
      jdk = jdk17_headless;
      offlineHash = "sha256-MLi62+xGKD0xVo9KbF90QKAm28TJqgg7rO23ouIDP6o=";
    };
    # https://maven.minecraftforge.net/net/minecraftforge/forge/1.20.1-47.2.17/forge-1.20.1-47.2.17-installer.jar
    "1.20.1-47.2.17" = {
      src = fetchurl {
        url = "https://maven.minecraftforge.net/net/minecraftforge/forge/1.20.1-47.2.17/forge-1.20.1-47.2.17-installer.jar";
        hash = "sha256-RBWlzZjG/Ysh7CvN7dulL9uo5JiVRXcK97K9IFRM1SQ=";
      };
      javaArgs = "@libraries/net/minecraftforge/forge/${version}/unix_args.txt";
      # Should be fine to use modern jdk versions on 1.2X.X
      jdk = jdk21_headless;
      offlineHash = "sha256-/xSyWwxBEkdUJgXj8NR/18mChukabCy2OdxX0aTI6wo=";
    };
    "1.20.1-47.3.0" = {
      src = fetchurl {
        url = "https://maven.minecraftforge.net/net/minecraftforge/forge/1.20.1-47.3.0/forge-1.20.1-47.3.0-installer.jar";
        hash = "sha256-YBirzpXMBYdo42WGX9fPO9MbXFUyMdr4hdw4X81th1o=";
      };
      javaArgs = "@libraries/net/minecraftforge/forge/${version}/unix_args.txt";
      # Should be fine to use modern jdk versions on 1.2X.X
      jdk = jdk21_headless;
      offlineHash = "sha256-2pjk8N6Pfxn4FdWzEvKsnywLBVsf1JLooJWHtireVic=";
    };
    "1.20.1-47.4.0" = {
      src = fetchurl {
        url = "https://maven.minecraftforge.net/net/minecraftforge/forge/1.20.1-47.4.0/forge-1.20.1-47.4.0-installer.jar";
        hash = "sha256-8/V0ZeLL3DKBk/d7p/DJTLZEBfMe1VZ1PZJ16L3Abiw=";
      };
      javaArgs = "@libraries/net/minecraftforge/forge/${version}/unix_args.txt";
      # Should be fine to use modern jdk versions on 1.2X.X
      jdk = jdk21_headless;
      offlineHash = "sha256-YOAU9B+cWnf9+N14FgNnot0QDuNeEVr1vLCij3Erch8=";
    };
  };
  forge = forgeVersions.${version};
  offline = runCommand "forge-offline" {
    outputHash = forge.offlineHash or lib.fakeHash;
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    nativeBuildInputs = [ openjdk_headless  ]; 
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

  rm libraries
  ln -svf ${offline}/libraries libraries

  exec java "\$@" ${forge.javaArgs} nogui
  EOF
  chmod +x $out/bin/$name
  patchShebangs $out/bin
 ''
