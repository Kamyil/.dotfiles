# Custom overlay for Claude Code release binaries.
#
# To update: change `version` and update the platform SHA-256 hashes from
# https://downloads.claude.ai/claude-code-releases/<version>/manifest.json.
final: prev: {
  claude-code = prev.stdenvNoCC.mkDerivation rec {
    pname = "claude-code";
    version = "2.1.283";

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
          "darwin-arm64" = "d8cb1e5c79684cc12a8bfc813e3a2073406921b6245744b3009be3ab5651d21e";
          "darwin-x64" = "c896d2aee12ff4d95861033d9730d3d22dc19e4f32779134d3399ef3dfb0e77a";
          "linux-arm64" = "346d294f0103d6fc0de11ac953579b5c62dfa90698a4cfc486b6f927c615e697";
          "linux-x64" = "1859583ce32920595c61ef868bee52e1b1594f7486db209935e01f1e5e804ae2";
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
