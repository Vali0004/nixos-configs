{ lib
, stdenv
, pkg-config
, glib
, makeWrapper
, maim
, rofi
, xdg-desktop-portal }:

stdenv.mkDerivation {
  pname = "xdg-desktop-portal-x11-screenshot";
  version = "0.1.0";
  src = ./.;

  nativeBuildInputs = [ pkg-config makeWrapper ];
  buildInputs = [ glib ];

  buildPhase = ''
    runHook preBuild
    substituteInPlace portal.c --replace-fail '@portal-xml@' \
      '${xdg-desktop-portal}/share/dbus-1/interfaces/org.freedesktop.impl.portal.Screenshot.xml'
    $CC -std=c11 -Wall -Wextra -Werror $(pkg-config --cflags gio-2.0) \
      portal.c -o xdg-desktop-portal-x11-screenshot \
      $(pkg-config --libs gio-2.0)
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 xdg-desktop-portal-x11-screenshot \
      $out/libexec/xdg-desktop-portal-x11-screenshot
    wrapProgram $out/libexec/xdg-desktop-portal-x11-screenshot \
      --set PATH ${lib.makeBinPath [ maim rofi ]}
    install -Dm644 x11-screenshot.portal \
      $out/share/xdg-desktop-portal/portals/x11-screenshot.portal
    install -Dm644 org.freedesktop.impl.portal.desktop.x11_screenshot.service \
      $out/share/dbus-1/services/org.freedesktop.impl.portal.desktop.x11_screenshot.service
    substituteInPlace $out/share/dbus-1/services/org.freedesktop.impl.portal.desktop.x11_screenshot.service \
      --replace-fail '@out@' "$out"
    runHook postInstall
  '';

  meta = {
    description = "Standalone X11 Screenshot portal backend";
    platforms = lib.platforms.linux;
    mainProgram = "xdg-desktop-portal-x11-screenshot";
  };
}
