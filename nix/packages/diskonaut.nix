{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "diskonaut";
  version = "0.11.0";

  src = fetchFromGitHub {
    owner = "imsnif";
    repo = "diskonaut";
    rev = version;
    hash = "sha256-pLQosVnAQZ82OUcR/wD8QnYs9JVJZ+HrB0NNkcdTq94=";
  };

  cargoLock.lockFile = "${src}/Cargo.lock";

  meta = {
    description = "Terminal disk space navigator";
    homepage = "https://github.com/imsnif/diskonaut";
    license = lib.licenses.mit;
    mainProgram = "diskonaut";
    platforms = lib.platforms.unix;
  };
}
