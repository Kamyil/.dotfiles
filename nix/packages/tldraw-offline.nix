{
  lib,
  stdenvNoCC,
  fetchurl,
  appimageTools,
  unzip,
}:

let
  pname = "tldraw-offline";
  version = "1.11.0";

  linuxSources = {
    x86_64-linux = fetchurl {
      url = "https://github.com/tldraw/tldraw-offline/releases/download/v${version}/tldraw-offline-linux-x86_64.AppImage";
      hash = "sha256-CUkGdHYz22gOYV5X+yAdB4yWi1Ii5zHJ53qgdnNEDgU=";
    };
    aarch64-linux = fetchurl {
      url = "https://github.com/tldraw/tldraw-offline/releases/download/v${version}/tldraw-offline-linux-arm64.AppImage";
      hash = "sha256-KU/SqNJIQclTynhwm1tN6tkFQ6M+Vu//EoStlOeUrpU=";
    };
  };

  meta = {
    description = "Local, file-based tldraw desktop whiteboard with agent integration";
    homepage = "https://offline.tldraw.com";
    license = lib.licenses.unfree;
    mainProgram = "tldraw-offline";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  };
in
if stdenvNoCC.hostPlatform.isLinux then
  appimageTools.wrapType2 {
    inherit pname version meta;
    src = linuxSources.${stdenvNoCC.hostPlatform.system};
  }
else
  stdenvNoCC.mkDerivation {
    inherit pname version meta;

    src = fetchurl {
      url = "https://github.com/tldraw/tldraw-offline/releases/download/v${version}/tldraw-offline-mac-universal.zip";
      hash = "sha256-nAYpLSv/rckcwSI+z7mTwqq5g9E4swk4Zl+PB458Qzc=";
    };

    nativeBuildInputs = [ unzip ];
    sourceRoot = ".";
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p "$out/Applications"
      cp -R "tldraw offline.app" "$out/Applications/"
      runHook postInstall
    '';
  }
