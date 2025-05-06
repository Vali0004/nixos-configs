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
  "patchouli_books" = {
    src = ./modpack/patchouli_books;
  };
  "scripts" = {
    src = ./modpack/scripts;
  };
  "mods" = {
    src = let
      mods_tar = runCommand "mods.tar.gz" {
        outputHash = "250fb524f7dfe7c15802c60a576f140df482ac8b4094e6c01df9dac61130cc4d";
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
