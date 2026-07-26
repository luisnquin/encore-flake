{
  lib,
  rustPlatform,
  protobuf,
  src,
  sourceRelease,
}:
rustPlatform.buildRustPackage {
  pname = "encore-tsparser";
  version = sourceRelease.version;
  inherit src;

  cargoHash = sourceRelease.cargoHash;
  cargoBuildFlags = [
    "-p"
    "encore-tsparser"
    "--bin"
    "tsparser-encore"
  ];

  nativeBuildInputs = [
    protobuf
    rustPlatform.bindgenHook
  ];

  ENCORE_VERSION = "v${sourceRelease.version}";

  doCheck = false;

  meta = {
    description = "Encore TypeScript parser";
    homepage = "https://encore.dev";
    license = lib.licenses.mpl20;
    mainProgram = "tsparser-encore";
  };
}
