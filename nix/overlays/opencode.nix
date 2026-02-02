# Custom overlay for opencode - fetches latest release from GitHub
# This creates a new package instead of overriding the nixpkgs one
#
# REQUIRES: programs.nix-ld.enable = true; in configuration.nix
# nix-ld provides /lib64/ld-linux-x86-64.so.2 that the binary expects
#
# To update: change `version` below and update the sha256 hash.
# Use lib.fakeHash temporarily to get the new hash from the build error.
final: prev: {
  opencode = prev.stdenv.mkDerivation rec {
    pname = "opencode";
    version = "1.1.48"; # GitHub release tag (without 'v' prefix)
    
    src = let
      # Determine platform-specific download URL
      platform = if prev.stdenv.isDarwin then
        if prev.stdenv.isAarch64 then "darwin-arm64" else "darwin-x64"
      else
        if prev.stdenv.isAarch64 then "linux-arm64" else "linux-x64";
      ext = if prev.stdenv.isDarwin then "zip" else "tar.gz";
    in
      prev.fetchurl {
        url = "https://github.com/anomalyco/opencode/releases/download/v${version}/opencode-${platform}.${ext}";
        # SHA256 for linux-x64 (glibc version)
        sha256 = "1g403v47zl1hd0im51wabis92d5yr9d1msn2izh38m116868h93m";
      };
    
    nativeBuildInputs = prev.lib.optionals prev.stdenv.isDarwin [ prev.unzip ];
    
    dontUnpack = true;
    dontConfigure = true;
    dontBuild = true;
    dontStrip = true;
    dontPatchELF = true;
    dontFixup = true;
    
    installPhase = ''
      runHook preInstall
      
      mkdir -p $out/bin
      
      # Extract the archive
      if [[ "$src" == *.zip ]]; then
        ${prev.unzip}/bin/unzip -j "$src" -d $out/bin
      else
        tar -xzf "$src" -C $out/bin
      fi
      
      chmod +x $out/bin/opencode
      
      runHook postInstall
    '';
    
    doInstallCheck = false;
    
    meta = with prev.lib; {
      description = "AI coding agent for the terminal";
      homepage = "https://github.com/anomalyco/opencode";
      license = licenses.mit;
      platforms = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      mainProgram = "opencode";
    };
  };
}
