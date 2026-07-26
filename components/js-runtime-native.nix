{
  lib,
  stdenv,
  rustPlatform,
  perl,
  cmake,
  protobuf,
  src,
  sourceRelease,
}:
rustPlatform.buildRustPackage {
  pname = "encore-js-runtime-native";
  version = sourceRelease.version;
  inherit src;

  cargoHash = sourceRelease.cargoHash;
  cargoBuildFlags = [
    "-p"
    "encore-js-runtime"
  ];

  nativeBuildInputs = [
    cmake
    perl
    protobuf
  ];

  preBuild = ''
    export TYPE_DEF_TMP_PATH="$TMPDIR/typedefs.ndjson"
    export ENCORE_VERSION="v${sourceRelease.version}"
    export ENCORE_WORKDIR="$TMPDIR"
  '';

  doCheck = false;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib $out/share/encore
    cp target/${stdenv.hostPlatform.rust.rustcTarget}/release/libencore_js_runtime${stdenv.hostPlatform.extensions.sharedLibrary} \
      $out/lib/encore-runtime.node
    cp "$TMPDIR/typedefs.ndjson" $out/share/encore/

    runHook postInstall
  '';

  meta = {
    description = "Native module for the Encore JavaScript runtime";
    homepage = "https://encore.dev";
    license = lib.licenses.mpl20;
  };
}
