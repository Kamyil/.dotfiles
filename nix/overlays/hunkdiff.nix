# Custom overlay for hunkdiff - review-first terminal diff viewer
# Fetches the npm meta-package (launcher) + platform-specific prebuilt binary
#
# To update: change `version` below and update the sha256 hashes.
# Use prev.lib.fakeHash temporarily to get the new hash from the build error.
final: prev:

let
  version = "0.10.0";

  platformInfo = if prev.stdenv.isDarwin then
    if prev.stdenv.isAarch64 then {
      binaryPkg = "hunkdiff-darwin-arm64";
      binaryHash = "09hgb7yzvwsfpp3gxpjzvgjf85njak7p8j0mgp5nmngdadwf62f3";
    } else {
      binaryPkg = "hunkdiff-darwin-x64";
      binaryHash = "13r8vygzqwvq2npakgk8cmkljq0h0pdnp60wxxnc3zpkqcxsgw9c";
    }
  else
    if prev.stdenv.isAarch64 then {
      binaryPkg = "hunkdiff-linux-arm64";
      binaryHash = "0phq4z67qif8i5h2lwrklm6a14v97q4zdwrh96c2m4r62xbywpzv";
    } else {
      binaryPkg = "hunkdiff-linux-x64";
      binaryHash = "083xvh247x06g56fdfg05a2w6lz6rxyh8m9v60rvfpxw59w1wa90";
    };
in

{
  hunkdiff = prev.stdenv.mkDerivation rec {
    pname = "hunkdiff";
    inherit version;

    src = prev.fetchurl {
      url = "https://registry.npmjs.org/hunkdiff/-/hunkdiff-${version}.tgz";
      sha256 = "05mnjgd0b7c13jh1ry8q1qcsxlyl5ygwdqd2z36a64wzpiq7vsn0";
    };

    nativeBuildInputs = [ prev.makeWrapper ];

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      mkdir -p $out/lib/node_modules/hunkdiff
      cp -R . $out/lib/node_modules/hunkdiff/
      chmod -R +w $out/lib/node_modules/hunkdiff

      mkdir -p $out/lib/node_modules/hunkdiff/node_modules/${platformInfo.binaryPkg}
      tar xzf ${prev.fetchurl {
        url = "https://registry.npmjs.org/${platformInfo.binaryPkg}/-/${platformInfo.binaryPkg}-${version}.tgz";
        sha256 = platformInfo.binaryHash;
      }} -C $out/lib/node_modules/hunkdiff/node_modules/${platformInfo.binaryPkg} --strip-components=1
      chmod +x $out/lib/node_modules/hunkdiff/node_modules/${platformInfo.binaryPkg}/bin/hunk

      mkdir -p $out/bin
      ln -s $out/lib/node_modules/hunkdiff/node_modules/${platformInfo.binaryPkg}/bin/hunk $out/bin/hunk
    '';

    meta = with prev.lib; {
      description = "Review-first terminal diff viewer for agentic coders";
      homepage = "https://github.com/modem-dev/hunk";
      license = licenses.mit;
      platforms = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      mainProgram = "hunk";
    };
  };
}
