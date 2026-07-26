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

  linuxSrc = linuxSources.${stdenvNoCC.hostPlatform.system};
  appimageContents = appimageTools.extractType2 {
    inherit pname version;
    src = linuxSrc;
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
    src = linuxSrc;
    extraInstallCommands = ''
      install -Dm444 ${appimageContents}/@tldesktop.desktop \
        $out/share/applications/tldraw-offline.desktop
      substituteInPlace $out/share/applications/tldraw-offline.desktop \
        --replace-fail "Exec=AppRun --no-sandbox %U" "Exec=tldraw-offline %U" \
        --replace-fail "Icon=@tldesktop" "Icon=tldraw-offline" \
        --replace-fail "MimeType=application/x-tldraw;application/x-tldraw;" "MimeType=application/x-tldraw;"

      for size in 16 24 32 48 64 96 128 256 512; do
        install -Dm444 \
          ${appimageContents}/usr/share/icons/hicolor/''${size}x''${size}/apps/@tldesktop.png \
          $out/share/icons/hicolor/''${size}x''${size}/apps/tldraw-offline.png
      done
    '';
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
