{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  pkg-config,
  libx11,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxft,
  libxinerama,
  libxrandr,
  libxrender,
  libxi,
  giflib,
  libjpeg_turbo,
  libpng,
  zlib,
}:

stdenv.mkDerivation {
  pname = "skippy-xd";
  version = "2026.11.14-unstable-2026-11-15";

  src = fetchFromGitHub {
    owner = "felixfung";
    repo = "skippy-xd";
    rev = "25402b43920965f4bfacadceb5b7dacbf5f6b026";
    hash = "sha256-yjpzjnv/MNZkTEtYp6NOlBzMYVIAOXJupjErLdn+yOk=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    libx11
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxft
    libxinerama
    libxrandr
    libxrender
    libxi
    giflib
    libjpeg_turbo
    libpng
    zlib
  ];

  mesonFlags = [
    "--sysconfdir=${placeholder "out"}/etc"
    "-Dskippy_chipmunk=disabled"
  ];

  # O meson.build define o teste 'dlist-sort' sem depender de servidor X
  doCheck = true;

  meta = {
    description = "Seletor de janelas e workspaces em tela cheia (overview/Exposé) para X11";
    homepage = "https://github.com/felixfung/skippy-xd";
    license = lib.licenses.gpl2Plus;
    mainProgram = "skippy-xd";
    platforms = lib.platforms.linux;
  };
}
