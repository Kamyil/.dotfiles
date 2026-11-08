# Custom overlay for Claude Code release binaries.
#
# To update, run:
#   scripts/update-claude-code-overlay.sh <version|latest|stable>
# Hashes come from
# https://downloads.claude.ai/claude-code-releases/<version>/manifest.json.
final: prev: {
  claude-code = prev.stdenvNoCC.mkDerivation rec {
    pname = "claude-code";
    version = "2.1.319";

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
          "darwin-arm64" = "1f53587e92dee8e089fa349188a4cda64fa34ace6e7b0ca2ee278ddaa3cc2ebd";
          "darwin-x64" = "af6f1f5510ae98d56a155bf8f007aa9d5b44efccc9c10c8e10ef35039e95a940";
          "linux-arm64" = "a7e687fd1cb054d651c7588223de3786c99d4c682365e3c3ae1e59ce7f3a591f";
          "linux-x64" = "dabafec82ca1319fa43d8be36a10fc61b1d11821cb98ad5df04ad95e199b8eed";
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
