{ runCommand }:

{
  "config" = {
    src = ./modpack/config;
  };
  "defaultconfigs" = {
    src = ./modpack/defaultconfigs;
  };
  "kubejs" = {
    src = ./modpack/kubejs;
  };
  "mods" = {
    src = let
      mods_tar = runCommand "mods.tar.gz" {
        outputHash = "b6cd53bdef82b93ad1ca7dfe5ba031f1959fd42724e23cc89b94510892ba5033";
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
  "resources" = {
    src = ./modpack/resources;
  };
  "scripts" = {
    src = ./modpack/scripts;
  };
  "server-icon.png" = {
    hash = "sha256-9QvXb9oxBpEIJGV0S25ofyriKTK5PUIt6b1z9uEvRW4=";
    url = "https://fuckk.lol/minecraft/image.png";
  };
}
