{
  fetchurl,
  lib,
  stdenvNoCC,
}:

let
  version = "0.1.18";
  sources = {
    aarch64-linux = {
      target = "linux-aarch64";
      hash = "sha256-zzM5PPlQu3Y3NNw+FmEKudr4SSORpO8N5WAmzX91KFM=";
    };
    x86_64-linux = {
      target = "linux-x86_64";
      hash = "sha256-Wy+Xy0sqnXprLMWUJiggPtn7t8wMK0sJrYpvVkjiRrc=";
    };
  };
  source = sources.${stdenvNoCC.hostPlatform.system};
in
stdenvNoCC.mkDerivation {
  pname = "herdr-core";
  inherit version;

  src = fetchurl {
    url = "https://releases.herdr.dev/core/${version}/herdr-core-${source.target}.tar.gz";
    inherit (source) hash;
  };

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    install -Dm755 herdr-core "$out/bin/herdr-core"
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
