{ runCommand }:

{
  "config" = {
    src = ./modpack/config;
  };
  "mods" = {
    src = let
      mods_tar = runCommand "mods.tar.gz" {
        outputHash = "73c967fab8b6e841894e5f94ad27b5a17418198d292a98cc677582a612c91fad";
        outputHashAlgo = "sha256";
        outputHashMode = "flat";
      } ''
        echo you need to run nix-store --add-fixed sha256 ./mods.tar.gz again
      '';
    in runCommand "mods" {} ''
      mkdir $out
      cd $out
      tar -xvf ${mods_tar}
    '';
  };
  "mods/skyboxloader-1.0.0-forge-1.20.1.jar" = {
    hash = "sha256-2V3dc0fm+8FeFrEwBLMjiu2JYVcyIqsgQJXWF+60Kmo=";
    url = "https://mediafilez.forgecdn.net/files/5398/839/skyboxloader-1.0.0-forge-1.20.1.jar";
  };
  "server-icon.png" = {
    hash = "sha256-9QvXb9oxBpEIJGV0S25ofyriKTK5PUIt6b1z9uEvRW4=";
    url = "https://fuckk.lol/minecraft/image.png";
  };
}
