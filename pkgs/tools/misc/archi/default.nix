{ lib, stdenv
, fetchurl
, fetchzip
, autoPatchelfHook
, makeWrapper
, jdk
, libsecret
, webkitgtk
, wrapGAppsHook
, _7zz
}:

stdenv.mkDerivation rec {
  pname = "Archi";
  version = "5.2.0";

  src =
    if stdenv.hostPlatform.system == "x86_64-linux" then
      fetchurl {
        url = "https://www.archimatetool.com/downloads/archi_5.php?/${version}/Archi-Linux64-${version}.tgz";
        sha256 = "0c28gwpfq42mw2xc05q3x2wybwxzjx4ixkvch515dvy4bmdbhrdq";
      }
    else if stdenv.hostPlatform.system == "x86_64-darwin" then
      fetchurl {
        url = "https://www.archimatetool.com/downloads/archi_5.php?/${version}/Archi-Mac-${version}.dmg";
        sha256 = "17xgynlvwp0mnzw7bykmjk64rig2pmrn6x1kfq8svfrh0qh5m3qq";
      }
    else if stdenv.hostPlatform.system == "aarch64-darwin" then
      fetchurl {
        url = "https://www.archimatetool.com/downloads/archi_5.php?/${version}/Archi-Mac-Silicon-${version}.dmg";
        sha256 = "1hfkj1snrbii5nx9mzzq2ngkj5bd2ys1gwb1w2k68f9nvnbss3r6";
      }
    else
      throw "Unsupported system";

  buildInputs = [
    libsecret
  ];

  nativeBuildInputs = [
    makeWrapper
    wrapGAppsHook
  ] ++ lib.optional stdenv.hostPlatform.isLinux autoPatchelfHook;

  unpackPhase = if stdenv.hostPlatform.isDarwin then ''
    ${_7zz}/bin/7zz x $src
  '' else null;

  installPhase =
    if stdenv.hostPlatform.system == "x86_64-linux" then
      ''
        mkdir -p $out/bin $out/libexec
        for f in configuration features p2 plugins Archi.ini; do
          cp -r $f $out/libexec
        done

        install -D -m755 Archi $out/libexec/Archi
        makeWrapper $out/libexec/Archi $out/bin/Archi \
          --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath ([ webkitgtk ])} \
          --prefix PATH : ${jdk}/bin
      ''
    else
      ''
        mkdir -p "$out/Applications"
        mv Archi.app "$out/Applications/"
      '';

  meta = with lib; {
    description = "ArchiMate modelling toolkit";
    longDescription = ''
      Archi is an open source modelling toolkit to create ArchiMate
      models and sketches.
    '';
    homepage = "https://www.archimatetool.com/";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = licenses.mit;
    platforms = platforms.linux ++ platforms.darwin;
    maintainers = with maintainers; [ earldouglas paumr ];
  };
}
