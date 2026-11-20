# Custom overlay for oh-my-pi release binaries.
#
# To update: change `version` below and update the sha256 hashes.
# Use lib.fakeHash temporarily to get a new platform hash from the build error.
final: prev: {
  omp = prev.stdenv.mkDerivation rec {
    pname = "omp";
    version = "19.0.1";

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
          "darwin-arm64" = "sha256-L+Qgu9APgYmYFuUcvuuVk6+lnZNo1iydPnhTXVQOMvY=";
          "darwin-x64" = "sha256-jWJQLu3ox6QzEXmENNCjGhwCSjq8Vr7cTaIAzM+U/qE=";
          "linux-arm64" = "sha256-I37eD0mU1h9SOALEz1YtTki650wYit15LQbQUbkHzs8=";
          "linux-x64" = "sha256-bO7wRDCFG7EFDG/aOvRnQS60ShHfCm/4Eh/mAQE8VBU=";
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
