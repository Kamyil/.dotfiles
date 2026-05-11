# Custom overlay for hunkdiff - review-first terminal diff viewer
# Fetches the npm meta-package (launcher) + platform-specific prebuilt binary
#
# To update: change `version` below and update the sha256 hashes.
# Use prev.lib.fakeHash temporarily to get the new hash from the build error.
final: prev:

let
  version = "0.12.0-beta.1";

  platformInfo = if prev.stdenv.isDarwin then
    if prev.stdenv.isAarch64 then {
      binaryPkg = "hunkdiff-darwin-arm64";
      binaryHash = "04b1yzfm6lmhcimj4a2dc9h90mw5h22sck6pw6jssxy7xa6xqd15";
    } else {
      binaryPkg = "hunkdiff-darwin-x64";
      binaryHash = "0hq2c4zrnv47v3y6qdxiy53zsxz2di7dkail3klpz82gxgwlsdcj";
    }
  else
    if prev.stdenv.isAarch64 then {
      binaryPkg = "hunkdiff-linux-arm64";
      binaryHash = "0i53ibwbqp1sabg6mry2vbmnw0s3v6pyv09dl17aabrqhv7aljs5";
    } else {
      binaryPkg = "hunkdiff-linux-x64";
      binaryHash = "1rarsxidpszrs5pr818883d9z605c21371xlzyc9khshpyib0ard";
    };
in

{
  hunkdiff = prev.stdenv.mkDerivation rec {
    pname = "hunkdiff";
    inherit version;

    src = prev.fetchurl {
      url = "https://registry.npmjs.org/hunkdiff/-/hunkdiff-${version}.tgz";
      sha256 = "0ppqjdrbkvfy5ns5ir6cl5iv8sy5003czz0g3psc9p428dajgm3w";
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
