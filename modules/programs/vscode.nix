{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.programs.vscode.enable {
    xdg.mime.defaultApplications."text/plain" = "code.desktop";

    environment.systemPackages = with pkgs; [
      vscode
      vscode-extensions.bbenoist.nix
      vscode-extensions.jnoortheen.nix-ide
      vscode-extensions.ms-vscode.cpptools-extension-pack
      vscode-extensions.ms-vscode.cmake-tools
      vscode-extensions.shardulm94.trailing-spaces
    ];
  };
}
