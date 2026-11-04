{
  autoPatchelfHook,
  fetchurl,
  lib,
  libGL,
  libgcc,
  libxcb,
  libxkbcommon,
  makeDesktopItem,
  copyDesktopItems,
  stdenv,
  vulkan-loader,
  wayland,
}:

let
  version = "0.1.12";
  sources = {
    aarch64-linux = {
      target = "linux-aarch64";
      hash = "sha256-dJ8x0w4/TX4k4nSPdNnLSpvdpMloAnq6/7b7I5/+tpQ=";
    };
    x86_64-linux = {
      target = "linux-x86_64";
      hash = "sha256-omXmySXEh0WEBnQf+gnS+g09S9QBo07YwBwzYQjlfB8=";
    };
  };
  source = sources.${stdenv.hostPlatform.system};
in
stdenv.mkDerivation {
  pname = "herdr-app";
  inherit version;

  src = fetchurl {
    url = "https://releases.herdr.dev/app/${version}/herdr-app-${source.target}.tar.gz";
    inherit (source) hash;
  };

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
  ];

  buildInputs = [
    libgcc
    libxcb
    libxkbcommon
  ];

  # GPUI dlopens its graphics and Wayland libraries at runtime.
  runtimeDependencies = [
    libGL
    vulkan-loader
    wayland
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "herdr-app";
      desktopName = "Herdr";
      comment = "Terminals and coding agents that keep running";
      exec = "herdr-app";
      icon = "herdr-app";
      categories = [ "Development" ];
      startupWMClass = "herdr-app";
    })
  ];

  installPhase = ''
    runHook preInstall
    install -Dm755 herdr-app "$out/bin/herdr-app"
    install -Dm644 herdr-app.svg "$out/share/icons/hicolor/scalable/apps/herdr-app.svg"
    runHook postInstall
  '';

  meta = {
    description = "Official Herdr desktop app for terminals and coding agents";
    homepage = "https://herdr.dev";
    license = lib.licenses.asl20;
    mainProgram = "herdr-app";
    platforms = builtins.attrNames sources;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
