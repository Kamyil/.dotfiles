{
  fetchurl,
  lib,
  stdenvNoCC,
}:

let
  version = "0.1.21";
  sources = {
    aarch64-darwin = {
      target = "macos-aarch64";
      hash = "sha256-GrON2ScPY6j3lNbWDocC6w0chacr2oXXNeXupD8F/+0=";
    };
    aarch64-linux = {
      target = "linux-aarch64";
      hash = "sha256-6ESiv6tIoiYJdnnQdryDBC/lf8zvU4fvgC5bJOeLUpo=";
    };
    x86_64-linux = {
      target = "linux-x86_64";
      hash = "sha256-eEJHVcEKQN3jigvbVcIKwZcG6a4F7Wj8Ks8fz/DZQcE=";
    };
  };
  source = sources.${stdenvNoCC.hostPlatform.system};
  isDarwin = stdenvNoCC.hostPlatform.isDarwin;
in
stdenvNoCC.mkDerivation {
  pname = "herdr-core";
  inherit version;

  src = fetchurl {
    url = "https://releases.herdr.dev/core/${version}/herdr-core-${source.target}.tar.gz";
    inherit (source) hash;
  };

  sourceRoot = ".";
  # On macOS the core runs from its signed Herdr Core.app bundle, so local
  # network and microphone permissions attach to it; keep the bundle intact.
  dontFixup = isDarwin;

  installPhase = ''
    runHook preInstall
  ''
  + (
    if isDarwin then
      ''
        mkdir -p "$out/Applications" "$out/bin"
        cp -R "Herdr Core.app" "$out/Applications/"
        ln -s "../Applications/Herdr Core.app/Contents/MacOS/herdr-core" "$out/bin/herdr-core"
      ''
    else
      ''
        install -Dm755 herdr-core "$out/bin/herdr-core"
      ''
  )
  + ''
    ln -s herdr-core "$out/bin/hc"
    runHook postInstall
  '';

  meta = {
    description = "Terminal server that keeps Herdr terminals and coding agents running";
    homepage = "https://herdr.dev";
    license = lib.licenses.asl20;
    mainProgram = "hc";
    platforms = builtins.attrNames sources;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
