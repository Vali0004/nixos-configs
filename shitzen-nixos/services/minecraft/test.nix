{ runCommand }:

{
  "config" = {
    src = ./modpack/config;
  };
  "ESM" = {
    src = ./modpack/ESM;
  };
  "kubejs" = {
    src = ./modpack/kubejs;
  };
  "mods" = {
    src = let
      mods_tar = runCommand "mods.tar.gz" {
        outputHash = "12459ff0cca2c51ee958944ef5d14768672d2ecfa81e8a87f825a68754adcd72";
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
  "server-icon.png" = {
    hash = "sha256-9QvXb9oxBpEIJGV0S25ofyriKTK5PUIt6b1z9uEvRW4=";
    url = "https://fuckk.lol/minecraft/image.png";
  };
}
