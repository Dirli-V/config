{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  gnutar,
  zlib,
  makeWrapper,
  maven,
  gradle,
}:
let
  version = "263.4702.0";
in
stdenv.mkDerivation {
  pname = "intellij-server";
  inherit version;

  src = fetchurl {
    url = "https://download.jetbrains.com/language-server/intellij-server/${version}/intellij-server-${version}.tar.gz";
    hash = "sha256-j6eWRzbULkSVLR/qelR4o7xugOJxA57mKm22xA/pWXA=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    gnutar
    makeWrapper
  ];

  buildInputs = [
    zlib
    stdenv.cc.cc.lib
  ];

  autoPatchelfIgnoreMissingDeps = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r . $out/
    wrapProgram $out/bin/intellij-server \
      --prefix PATH : ${lib.makeBinPath [ maven gradle ]}
    runHook postInstall
  '';

  meta = {
    description = "JetBrains IntelliJ IDEA Language Server";
    homepage = "https://www.jetbrains.com/";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "intellij-server";
  };
}
