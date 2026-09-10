# Custom overlay for oh-my-pi release binaries.
#
# To update: change `version` below and update the sha256 hashes.
# Use lib.fakeHash temporarily to get a new platform hash from the build error.
final: prev: {
  omp = prev.stdenv.mkDerivation rec {
    pname = "omp";
    version = "18.1.16";

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
          "darwin-arm64" = "sha256-me7W1F2YTS8T12gy94eCuaoHhikhq06Y4tjjHKgSl5U=";
          "darwin-x64" = "sha256-eLEdSp9YhOGFidKosQ4yj2ltW32h9v5G8om7gPVf/d8=";
          "linux-arm64" = "sha256-2GEjicevPPO2lgnJFJv/PPB9y2V3SyMdncSWaxdrlyA=";
          "linux-x64" = "sha256-7+vvt0NZ0gNi4HNB8Bpl/AolnnvHlFTvCLDr9SMquJc=";
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
