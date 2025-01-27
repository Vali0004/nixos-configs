 { lib, runCommand, version, fetchurl, openjdk, openjdk_headless, jdk21_headless, jdk8_headless, jdk11_headless }:

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
    "1.16.5-36.2.39" = {
      src = fetchurl {
        url = "https://maven.minecraftforge.net/net/minecraftforge/forge/1.16.5-36.2.39/forge-1.16.5-36.2.39-installer.jar";
        hash = "sha256-vCO9DgxvF6ff3dvqZfAIyBJq2Pm7hLmkcGmiuo0C/M0=";
      };
      javaArgs = "${offline}/forge-${version}.jar";
      jdk = jdk11_headless;
      offlineHash = "sha256-bGYgqwM8VS1RORPbRFDZDlt7N2MOHssXtDz9qefeE4s=";
    };
    "1.16.5-36.2.42" = {
      src = fetchurl {
        url = "https://maven.minecraftforge.net/net/minecraftforge/forge/1.16.5-36.2.42/forge-1.16.5-36.2.42-installer.jar";
        hash = "sha256-36kMaB8wviQGVItkKbzLaNla9PZKsZuMWPYSj9UP+Fc=";
      };
      javaArgs = "-jar ${offline}/forge-${version}.jar";
      jdk = jdk11_headless;
      offlineHash = "sha256-dmHB8KsVLXjIjgd97R9R0x6ZBxt3pADV2ERbWio8Gww=";
    };
    #https://maven.minecraftforge.net/net/minecraftforge/forge/1.20.1-47.3.0/forge-1.20.1-47.3.0-installer.jar   
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

  ln -svf ${offline}/libraries libraries

  exec java "\$@" ${forge.javaArgs} nogui
  EOF
  chmod +x $out/bin/$name
  patchShebangs $out/bin
 ''
