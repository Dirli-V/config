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
  jdk25,
}:
let
  version = "263.3533.0";
in
stdenv.mkDerivation {
  pname = "intellij-server";
  inherit version;

  src = fetchurl {
    url = "https://download.jetbrains.com/language-server/intellij-server/${version}/intellij-server-${version}.tar.gz";
    sha256 = "1arv3i0p12axz6kq6p5jxvkdrv9pmx91113dk6iw719hnlnrpwwn";
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
    mkdir -p $out/bin
    makeWrapper $out/intellij-server $out/bin/intellij-server \
      --prefix PATH : ${lib.makeBinPath [ maven gradle jdk25 ]}
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
