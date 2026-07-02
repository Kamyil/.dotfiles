# Custom overlay for opencode - fetches latest release from GitHub
# This creates a new package instead of overriding the nixpkgs one
#
# REQUIRES: programs.nix-ld.enable = true; in configuration.nix
# nix-ld provides /lib64/ld-linux-x86-64.so.2 that the binary expects
#
# To update quickly on the current machine, run:
#   scripts/update-opencode-overlay.sh <version>
final: prev: {
  opencode = prev.stdenv.mkDerivation rec {
    name = "opencode";
    version = "1.17.13"; # GitHub release tag (without 'v' prefix)
    
    src = let
      # Determine platform-specific download URL
      platform = if prev.stdenv.isDarwin then
        if prev.stdenv.isAarch64 then "darwin-arm64" else "darwin-x64"
      else
        if prev.stdenv.isAarch64 then "linux-arm64" else "linux-x64";
      ext = if prev.stdenv.isDarwin then "zip" else "tar.gz";
      # Platform-specific hashes
      hashes = {
        "darwin-arm64" = "sha256-3QFtPiazR9Z1qybEXR4odUWRLVxMSfoHcLYi1KE2fiM=";
        "darwin-x64" = "sha256-C/PZ0TQJfKaYuD9kxV25YNbS0MQJBpv0z9hj5d5QO0o=";
        "linux-arm64" = "sha256-u6zN03Sqq2bNl8f4rRwICqOTYQ+l+A7o38AH+VAK+vk=";
        "linux-x64" = "sha256-FXr6KJ0ajZNy3gzhmscmEZuTeh9rIBgI1G8G5OWbs0g=";
      };
    in
      prev.fetchurl {
        name = "opencode-${version}-${platform}.${ext}";
        url = "https://github.com/anomalyco/opencode/releases/download/v${version}/opencode-${platform}.${ext}";
        sha256 = hashes.${platform};
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
