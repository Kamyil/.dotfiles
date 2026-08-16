{
  fetchFromGitHub,
  fetchurl,
  qt6Packages,
  stdenv,
  cmake,
  grim,
  hyprland,
  kdePackages,
  lib,
  makeWrapper,
  ninja,
  pkg-config,
  tesseract,
  wayland,
  wayland-protocols,
  wayland-scanner,
  wl-clipboard,
  xdg-utils,
}:

let
  tessdataEng = fetchurl {
    url = "https://raw.githubusercontent.com/tesseract-ocr/tessdata_fast/main/eng.traineddata";
    hash = "sha256-fUMivSp3SXJIeWg/w5EstULxmQbIO8waUhMlVkJxcLI=";
  };
in
stdenv.mkDerivation {
  pname = "omasnap";
  version = "1.0.6";

  src = fetchFromGitHub {
    owner = "tobi";
    repo = "omasnap";
    tag = "v1.0.6";
    hash = "sha256-J+od6dn5qMhHphvpqeu4JD846fNAk1NikUJDl0Hi+sY=";
  };
  nativeBuildInputs = [
    cmake
    makeWrapper
    ninja
    pkg-config
    qt6Packages.wrapQtAppsHook
    wayland-scanner
  ];

  buildInputs = [
    kdePackages.qtbase
    kdePackages.layer-shell-qt
    wayland
    wayland-protocols
  ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail /usr/share/wayland-protocols \
        ${wayland-protocols}/share/wayland-protocols
  '';

  postInstall = ''
    install -Dm444 ${tessdataEng} $out/share/tessdata/eng.traineddata
    wrapProgram $out/bin/omasnap \
      --set TESSDATA_PREFIX "$out/share/tessdata" \
      --prefix PATH : ${
        lib.makeBinPath [
          grim
          hyprland
          tesseract
          wl-clipboard
          xdg-utils
        ]
      }
  '';

  meta = {
    description = "Native Wayland screenshot and annotation editor for Hyprland";
    homepage = "https://github.com/tobi/omasnap";
    license = lib.licenses.mit;
    mainProgram = "omasnap";
    platforms = lib.platforms.linux;
  };
}
