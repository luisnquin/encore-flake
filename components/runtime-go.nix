{
  lib,
  stdenvNoCC,
  src,
  sourceRelease,
}:
stdenvNoCC.mkDerivation {
  pname = "encore-runtime-go";
  version = sourceRelease.version;
  inherit src;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/runtimes
    cp -r runtimes/go $out/runtimes/

    runHook postInstall
  '';

  meta = {
    description = "Encore Go runtime sources";
    homepage = "https://encore.dev";
    license = lib.licenses.mpl20;
  };
}
