{
  fetchurl,
  lib,
  stdenvNoCC,
}:

let
  version = "0.12.0";
  sources = {
    aarch64-darwin = {
      archive = "darwin_arm64";
      hash = "sha256-YU4uyBKo9lmVAmjkCoQxTaDGPNV3MBzqgMbDIWD86q8=";
    };
    x86_64-darwin = {
      archive = "darwin_x86_64";
      hash = "sha256-fYdGpcM/yIHbZBPFo2hv6Mg6bgvV2/d8jVSnEBjpqiM=";
    };
    aarch64-linux = {
      archive = "linux_arm64";
      hash = "sha256-9Z0TMnE8HPwC3UM4FX+o5m2aGKACee6d4NH1cU0uwXc=";
    };
    x86_64-linux = {
      archive = "linux_x86_64";
      hash = "sha256-Dc5o/hwtnkDFJC9SDMbXO1anRTDTxj1mktFKAKAIhxI=";
    };
  };
  source = sources.${stdenvNoCC.hostPlatform.system};
in
stdenvNoCC.mkDerivation {
  pname = "slk";
  inherit version;

  src = fetchurl {
    url = "https://github.com/gammons/slk/releases/download/v${version}/slk_${version}_${source.archive}.tar.gz";
    inherit (source) hash;
  };

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    install -Dm755 slk "$out/bin/slk"
    runHook postInstall
  '';

  meta = {
    description = "Blazingly fast Slack TUI";
    homepage = "https://github.com/gammons/slk";
    license = lib.licenses.mit;
    mainProgram = "slk";
    platforms = builtins.attrNames sources;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
