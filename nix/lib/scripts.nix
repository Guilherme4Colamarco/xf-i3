# Empacota os scripts do diretório bin/ com PATH e padrões de ambiente para NixOS.
{
  pkgs,
  lib,
  iris-colors,
  skippy-xd,
  enableBrilho ? false,
  brilhoBus ? null,
  wallpaperDirs ? [ ],
}:

let
  runtimePath = lib.makeBinPath (
    with pkgs;
    [
      coreutils
      gnused
      gawk
      findutils
      util-linux
      procps
      jq
      feh
      rofi
      libnotify
      i3
      xfconf
      glib
      fish
      iris-colors
      skippy-xd
    ]
    ++ lib.optional enableBrilho ddcutil
  );

  plainScripts = [
    "i3-ws"
    "i3-dynamic-ws"
    "i3-desktop-mode"
    "i3-xfce-wsnames"
  ];
in
pkgs.stdenv.mkDerivation {
  pname = "rice-scripts";
  version = "0.1.0";

  src = ../../bin;
  dontUnpack = true;
  dontBuild = true;

  nativeBuildInputs = [ pkgs.makeWrapper ];

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin"

    for name in ${lib.escapeShellArgs plainScripts}; do
      install -Dm755 "$src/$name" "$out/bin/$name"
      wrapProgram "$out/bin/$name" \
        --prefix PATH : "${runtimePath}"
    done

    install -Dm755 "$src/iris-wall" "$out/bin/iris-wall"
    wrapProgram "$out/bin/iris-wall" \
      --prefix PATH : "${runtimePath}" \
      --set-default IRIS_BASE_THEME_DIR "${pkgs.adw-gtk3}/share/themes" \
      ${lib.optionalString (wallpaperDirs != [ ]) ''--set-default IRIS_WALL_DIRS "${lib.concatStringsSep ":" wallpaperDirs}"''}

    ${lib.optionalString enableBrilho ''
      install -Dm755 "$src/brilho" "$out/bin/brilho"
      wrapProgram "$out/bin/brilho" \
        --prefix PATH : "${runtimePath}" \
        --set-default BRILHO_BUS "${if brilhoBus == null then "auto" else toString brilhoBus}"
    ''}

    runHook postInstall
  '';
}
