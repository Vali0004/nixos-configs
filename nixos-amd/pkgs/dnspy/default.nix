{ lib,
  fetchurl,
  makeDesktopItem,
  symlinkJoin,
  writeShellScriptBin,
  wineWowPackages,
  winetricks,
  wineFlags ? "",
  pname ? "dnspy",
  location ? "$HOME/.local/share/wineprefixes/dnspy-wineprefix",
  tricks ? ["dotnet48" "gdiplus"],
  preCommands ? "",
  postCommands ? "",
}: let

  # Download dnSpy zip from GitHub
  src = fetchurl rec {
    url = "https://github.com/dnSpyEx/dnSpy/releases/download/v6.5.1/dnSpy-net-win64.zip";
    hash = "sha256-e04W/97e1+J3hTd/EQOI5K+1IlDUYGJG1SFU6TW+Dug=";
  };

  # Format winetricks arguments
  tricksFmt = with builtins;
    if (length tricks) > 0
    then concatStringsSep " " tricks
    else "-V";

  script = writeShellScriptBin pname ''
    export WINEPREFIX="${location}"

    PATH=${lib.makeBinPath [wineWowPackages.stable winetricks]}:$PATH

    DNSPY="$WINEPREFIX/drive_c/dnSpy/dnSpy.exe"

    if [ ! -d "$WINEPREFIX" ]; then
      # Install winetricks dependencies
      winetricks -q -f ${tricksFmt}
      wineserver -k

      # Extract dnSpy
      mkdir -p "$WINEPREFIX/drive_c/dnSpy"
      unzip ${src} -d "$WINEPREFIX/drive_c/dnSpy"
    fi

    ${preCommands}

    # Launch dnSpy
    wine ${wineFlags} "$DNSPY" "$@"
    wineserver -w

    ${postCommands}
  '';

  desktopItems = makeDesktopItem {
    name = pname;
    exec = "${script}/bin/${pname} %U";
    comment = ".NET Assembly Editor";
    desktopName = "dnSpy";
    categories = ["Development"];
  };
in
symlinkJoin {
  name = pname;
  paths = [
    desktopItems
    script
  ];

  meta = {
    description = "dnSpy .NET Assembly Editor with Wine wrapper";
    homepage = "https://github.com/dnSpy/dnSpy";
    license = lib.licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
  };
}
