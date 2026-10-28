# Custom overlay for Claude Code release binaries.
#
# To update, run:
#   scripts/update-claude-code-overlay.sh <version|latest|stable>
# Hashes come from
# https://downloads.claude.ai/claude-code-releases/<version>/manifest.json.
final: prev: {
  claude-code = prev.stdenvNoCC.mkDerivation rec {
    pname = "claude-code";
    version = "2.1.304";

    src =
      let
        platform =
          if prev.stdenv.isDarwin then
            if prev.stdenv.isAarch64 then "darwin-arm64" else "darwin-x64"
          else if prev.stdenv.isAarch64 then
            "linux-arm64"
          else
            "linux-x64";
        hashes = {
          "darwin-arm64" = "b9ac5374839f14abf3f1f45610637c332b5daee5ce0d1634726cef87aab78e6a";
          "darwin-x64" = "f2ae409b46b1bdc1dec7afa12c6a094ff64e7d4ca272ca09f69dd0080c846703";
          "linux-arm64" = "c487117526509ab6d2ee6013e14f181faf68d6d6afe6bb0d4b2b4a9feca5ecb3";
          "linux-x64" = "ea0f135784631619a7a409d07322ecec964f9cc4fd377508ed1ba3f141f27912";
        };
      in
      prev.fetchurl {
        url = "https://downloads.claude.ai/claude-code-releases/${version}/${platform}/claude";
        sha256 = hashes.${platform};
      };

    __noChroot = prev.stdenv.hostPlatform.isDarwin;
    dontUnpack = true;
    dontBuild = true;
    dontStrip = true;

    nativeBuildInputs = [ prev.makeBinaryWrapper ]
      ++ prev.lib.optionals prev.stdenv.hostPlatform.isElf [ prev.autoPatchelfHook ];

    buildInputs = prev.lib.optionals prev.stdenv.hostPlatform.isLinux [ prev.alsa-lib ];

    installPhase = ''
      runHook preInstall

      install -d "$out/bin"
      install -Dm755 "$src" "$out/bin/claude"

      wrapProgram "$out/bin/claude" \
        --set DISABLE_AUTOUPDATER 1 \
        --set-default FORCE_AUTOUPDATE_PLUGINS 1 \
        --set DISABLE_INSTALLATION_CHECKS 1 \
        --set USE_BUILTIN_RIPGREP 0 \
        ${prev.lib.optionalString prev.stdenv.hostPlatform.isLinux ''
          --prefix LD_LIBRARY_PATH : ${prev.lib.makeLibraryPath [ prev.alsa-lib ]} \
        ''}--prefix PATH : ${prev.lib.makeBinPath (
          [ prev.procps prev.ripgrep ]
          ++ prev.lib.optionals prev.stdenv.hostPlatform.isLinux [ prev.bubblewrap prev.socat ]
        )}

      runHook postInstall
    '';

    meta = with prev.lib; {
      description = "Agentic coding tool that lives in your terminal";
      homepage = "https://github.com/anthropics/claude-code";
      license = licenses.unfree;
      platforms = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      mainProgram = "claude";
    };
  };
}
