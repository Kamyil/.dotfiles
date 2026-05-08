{ lib, stdenv, fetchurl, makeWrapper }:

let
  version = "0.10.0";

  systemMapping = {
    "x86_64-linux" = { platArch = "linux-x64"; hash = "083xvh247x06g56fdfg05a2w6lz6rxyh8m9v60rvfpxw59w1wa90"; };
    "aarch64-linux" = { platArch = "linux-arm64"; hash = "0phq4z67qif8i5h2lwrklm6a14v97q4zdwrh96c2m4r62xbywpzv"; };
    "x86_64-darwin" = { platArch = "darwin-x64"; hash = "13r8vygzqwvq2npakgk8cmkljq0h0pdnp60wxxnc3zpkqcxsgw9c"; };
    "aarch64-darwin" = { platArch = "darwin-arm64"; hash = "09hgb7yzvwsfpp3gxpjzvgjf85njak7p8j0mgp5nmngdadwf62f3"; };
  };

  platform = systemMapping.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
in

stdenv.mkDerivation rec {
  pname = "hunkdiff";
  inherit version;

  src = fetchurl {
    url = "https://registry.npmjs.org/hunkdiff/-/hunkdiff-${version}.tgz";
    hash = "sha256-05mnjgd0b7c13jh1ry8q1qcsxlyl5ygwdqd2z36a64wzpiq7vsn0";
  };

  platformSrc = fetchurl {
    url = "https://registry.npmjs.org/hunkdiff-${platform.platArch}/-/hunkdiff-${platform.platArch}-${version}.tgz";
    hash = "sha256-${platform.hash}";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/lib/node_modules/hunkdiff
    cp -R . $out/lib/node_modules/hunkdiff/
    chmod -R +w $out/lib/node_modules/hunkdiff

    mkdir -p $out/lib/node_modules/hunkdiff/node_modules/hunkdiff-${platform.platArch}
    tar xzf $platformSrc -C $out/lib/node_modules/hunkdiff/node_modules/hunkdiff-${platform.platArch} --strip-components=1
    chmod +x $out/lib/node_modules/hunkdiff/node_modules/hunkdiff-${platform.platArch}/bin/hunk

    mkdir -p $out/bin
    ln -s $out/lib/node_modules/hunkdiff/node_modules/hunkdiff-${platform.platArch}/bin/hunk $out/bin/hunk
  '';

  meta = {
    description = "Review-first terminal diff viewer for agentic coders";
    homepage = "https://github.com/modem-dev/hunk";
    license = lib.licenses.mit;
    platforms = builtins.attrNames systemMapping;
  };
}
