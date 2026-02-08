# Custom overlay for codex-cli - fetches latest release from GitHub
# This creates a new package for OpenAI's codex CLI
#
# To update: change `version` below and update the sha256 hash.
# Use lib.fakeHash temporarily to get the new hash from the build error.
final: prev: {
  codex = prev.stdenv.mkDerivation rec {
    pname = "codex";
    version = "0.98.0"; # GitHub release version (tag is 'rust-v{version}')
    
    src = let
      # Determine platform-specific download URL
      platform = if prev.stdenv.isDarwin then
        if prev.stdenv.isAarch64 then "aarch64-apple-darwin" else "x86_64-apple-darwin"
      else
        if prev.stdenv.isAarch64 then "aarch64-unknown-linux-musl" else "x86_64-unknown-linux-musl";
    in
      prev.fetchurl {
        url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-${platform}.tar.gz";
        # Platform-specific SHA256 hashes
        # To update: set to prev.lib.fakeHash, build, then copy the actual hash from the error
        sha256 = if prev.stdenv.isDarwin then
          (if prev.stdenv.isAarch64 then
            "sha256-PMdXcogDruDEyZTFaCENmQCrxs7GC+Aj57LApuMBglU="
          else
            prev.lib.fakeHash)  # x86_64-darwin
        else
          (if prev.stdenv.isAarch64 then
            prev.lib.fakeHash   # aarch64-linux
          else
            prev.lib.fakeHash); # x86_64-linux
      };
    
    nativeBuildInputs = [ prev.gzip ];
    
    dontUnpack = true;
    dontConfigure = true;
    dontBuild = true;
    dontStrip = true;
    
    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin

      # Extract the tarball
      tar -xzf "$src" -C $out/bin

      # The binary is named with platform suffix, rename to just 'codex'
      mv $out/bin/codex-* $out/bin/codex

      # Make sure it's executable
      chmod +x $out/bin/codex

      runHook postInstall
    '';
    
    doInstallCheck = false;
    
    meta = with prev.lib; {
      description = "Lightweight coding agent that runs in your terminal";
      homepage = "https://github.com/openai/codex";
      license = licenses.asl20;
      platforms = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      mainProgram = "codex";
    };
  };
}
