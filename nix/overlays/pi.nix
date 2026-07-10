# Custom overlay for Pi Coding Agent - fetches GitHub release archives.
#
# To update: change `version` below and update the sha256 hashes.
# Use lib.fakeHash temporarily to get a new platform hash from the build error.
final: prev: {
  omp = prev.stdenv.mkDerivation rec {
    pname = "omp";
    version = "16.3.6";

    src = let
      platform = if prev.stdenv.isDarwin then
        if prev.stdenv.isAarch64 then "darwin-arm64" else "darwin-x64"
      else
        if prev.stdenv.isAarch64 then "linux-arm64" else "linux-x64";
      hashes = {
        "darwin-arm64" = "sha256-Ebwkjps6Ig+FnrR1ivhgmsZgZLb//GzqhicdzYHhguQ=";
        "darwin-x64" = "sha256-ObL0cZVotD+J5tfZ2jaJWuqcnrGtW5Ruhbbt3OCoo9E=";
        "linux-arm64" = "sha256-gsYttvqIHWaG8JKeMolSA+/7la8i+BYSxovh3XiH9dQ=";
        "linux-x64" = "sha256-oqI1QDJINVN4Nj33U7GnL0nQsnlMnhonrPUvTOKG20c=";
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
      platforms = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      mainProgram = "omp";
    };
  };

  pi = prev.stdenv.mkDerivation rec {
    pname = "pi";
    version = "0.73.1";

    src = let
      platform = if prev.stdenv.isDarwin then
        if prev.stdenv.isAarch64 then "darwin-arm64" else "darwin-x64"
      else
        if prev.stdenv.isAarch64 then "linux-arm64" else "linux-x64";
      hashes = {
        "darwin-arm64" = "sha256-xk9QHK2PoKWBJX3J6HjhsvNR8pXQ2F1XP+jXlnv7G+4=";
        "linux-x64" = "sha256-APDbnpP2ujPesbtNdbTq/t6fpTebY1qQjPln1bN+Nm0=";
        "darwin-x64" = prev.lib.fakeHash;
        "linux-arm64" = prev.lib.fakeHash;
      };
    in
      prev.fetchurl {
        url = "https://github.com/earendil-works/pi/releases/download/v${version}/pi-${platform}.tar.gz";
        sha256 = hashes.${platform};
      };

    dontConfigure = true;
    dontBuild = true;
    dontStrip = true;
    dontPatchELF = true;
    dontFixup = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share $out/bin
      tar -xzf "$src" -C $out/share
      chmod +x $out/share/pi/pi
      ln -s $out/share/pi/pi $out/bin/pi

      runHook postInstall
    '';

    meta = with prev.lib; {
      description = "Minimal terminal coding agent";
      homepage = "https://github.com/earendil-works/pi";
      license = licenses.asl20;
      platforms = [ "x86_64-linux" "aarch64-darwin" ];
      mainProgram = "pi";
    };
  };
}
