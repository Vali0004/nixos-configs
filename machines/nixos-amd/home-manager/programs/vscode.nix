{
  programs.vscode = {
    enable = true;
    profiles.default = {
      userSettings = {
        "editor.wordWrap" = "on";
        "explorer.confirmDelete" = false;
        "explorer.confirmDragAndDrop" = false;
        "files.autoSave" = "afterDelay";
        "files.autoSaveDelay" = 1000;
        "files.externalFileExplorer" = "nemo";
        "terminal.integrated.defaultProfile.linux" = "zsh";
        "security.workspace.trust.untrustedFiles" = "open";
        "C_Cpp.default.compilerPath" = "";
        "files.exclude" = {
          "**/.git" = false;
          "**/.svn" = false;
          "**/.hg" = false;
          "**/.DS_Store" = false;
          "**/Thumbs.db" = false;
        };
      };
    };
  };
}