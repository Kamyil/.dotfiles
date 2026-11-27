# Codex CLI release binaries for the supported macOS and NixOS hosts.
final: prev:
let
  version = "0.172.0";
  platform =
    if prev.stdenv.hostPlatform.system == "aarch64-darwin" then
      "aarch64-apple-darwin"
    else if prev.stdenv.hostPlatform.system == "x86_64-linux" then
      "x86_64-unknown-linux-musl"
    else
      throw "codex overlay: unsupported system ${prev.stdenv.hostPlatform.system}";
  hashes = {
    aarch64-apple-darwin = "sha256-vRIfir1rKLP8R22gSjSOJag+ie2hnTkQf2j46WYFMJI=";
    x86_64-unknown-linux-musl = "sha256-ojQqj39o8Ii+MGIMz+nLhBYsk6a1YXeFWWHNo+1r45I=";
  };
  hostHashes = {
    aarch64-apple-darwin = "sha256-6rJPiObiDIgdjBG39w7iIP0ZqUxYbsa86tEqIOAstuQ=";
    x86_64-unknown-linux-musl = "sha256-ILCkvPMyQVpZl5FMlD0Er2w2J68MN5/b9lQAVQ41K7Q=";
  };
in
{
  codex = prev.stdenvNoCC.mkDerivation {
    pname = "codex";
    inherit version;

    src = prev.fetchurl {
      url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-${platform}.tar.gz";
      hash = hashes.${platform};
    };
    hostSrc = prev.fetchurl {
      url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-code-mode-host-${platform}.tar.gz";
      hash = hostHashes.${platform};
    };

    nativeBuildInputs = [ prev.makeWrapper ];
    dontUnpack = true;
    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      tar -xzf $src -C $out/bin
      tar -xzf $hostSrc -C $out/bin
      mv $out/bin/codex-${platform} $out/bin/codex
      mv $out/bin/codex-code-mode-host-${platform} $out/bin/codex-code-mode-host
      chmod +x $out/bin/codex $out/bin/codex-code-mode-host
      wrapProgram $out/bin/codex --add-flags --no-daemon
      runHook postInstall
    '';

    meta = with prev.lib; {
      description = "Lightweight coding agent that runs in your terminal";
      homepage = "https://github.com/openai/codex";
      license = licenses.asl20;
      platforms = [ "aarch64-darwin" "x86_64-linux" ];
      mainProgram = "codex";
    };
  };
}
