# Custom overlay for oh-my-pi release binaries.
#
# To update: change `version` below and update the sha256 hashes.
# Use lib.fakeHash temporarily to get a new platform hash from the build error.
final: prev: {
  omp = prev.stdenv.mkDerivation rec {
    pname = "omp";
    version = "18.0.11";

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
          "darwin-arm64" = "sha256-iLSj5o4ZkEuPzBuksxnvaHlfT+BqbRAdVk/EgssMwlI=";
          "darwin-x64" = "sha256-gPfcV5uI0OVbXOTrTQ6UBxGvaTKPT/ssKTuOFJf/ei0=";
          "linux-arm64" = "sha256-5fd8tlqi3Hd6ilkyvjsuakQnHI3y6yCc6m8E8hLz8BA=";
          "linux-x64" = "sha256-YFRGCynputXrp4M28pHhl5wvoKXNlvwtkq/WZsxoHSY=";
        };
      in
      prev.fetchurl {
        url = "https://github.com/can1357/oh-my-pi/releases/download/v${version}/omp-${platform}";
        hash = hashes.${platform};
      };

    dontUnpack = true;
    dontConfigure = true;
    dontBuild = true;
    dontStrip = true;
    dontPatchELF = true;
    dontFixup = true;

    installPhase = ''
      runHook preInstall

      install -Dm755 "$src" $out/bin/omp

      runHook postInstall
    '';

    meta = with prev.lib; {
      description = "Coding agent with the IDE wired in";
      homepage = "https://omp.sh";
      license = licenses.mit;
      platforms = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      mainProgram = "omp";
    };
  };

}
