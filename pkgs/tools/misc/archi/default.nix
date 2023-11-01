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
  version = "5.1.0";

  src =
    if stdenv.hostPlatform.system == "x86_64-linux" then
      fetchurl {
        url = "https://www.archimatetool.com/downloads/archi-5.php?/${version}/Archi-Linux64-${version}.tgz";
        sha256 = "1bv7xsjvxzr366zij1hy8mlsn6is3ykh1p50dkjxqg02f8k8cspm";
      }
    else if stdenv.hostPlatform.system == "x86_64-darwin" then
      fetchzip {
        url = "https://www.archimatetool.com/downloads/archi-5.php?/${version}/Archi-Mac-${version}.dmg";
        sha256 = "11z8xq3m0m8kpdwwldsjnhsf0wk7ybwsa5l9wfj215aj0dqk0w0y";
      }
    else if stdenv.hostPlatform.system == "aarch64-darwin" then
      fetchzip {
        url = "https://www.archimatetool.com/downloads/archi-5.php?/${version}/Archi-Mac-Silicon-${version}.dmg";
        sha256 = "0ajsmnag1wn84kxczm3xnlyfycyy1hq6gswgvjl6xzlryjrigvf2";
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

  unpackPhase = if stdenv.isDarwin then ''
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
