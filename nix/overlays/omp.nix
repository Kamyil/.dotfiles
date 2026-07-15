# Custom overlay for oh-my-pi release binaries.
#
# To update: change `version` below and update the sha256 hashes.
# Use lib.fakeHash temporarily to get a new platform hash from the build error.
final: prev: {
  omp = prev.stdenv.mkDerivation rec {
    pname = "omp";
    version = "16.5.0";

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
          "darwin-arm64" = "sha256-CMmy5s/rS/E3jb9aQLIR1f2lbnMfsBrOBt9amapqRHw=";
          "darwin-x64" = "sha256-LAbMY2gBkVjm6LsRUcrJae5anhNyXSdVteQjXsDnSPw=";
          "linux-arm64" = "sha256-ho95rmIiIGBxE4RUsa2V4fKEoET7YCcawJGmRGTrJsc=";
          "linux-x64" = "sha256-B4gqZJ7+CqAp/xDUenF6qrGAOSyq2ZKttUS6aHrAaoA=";
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
