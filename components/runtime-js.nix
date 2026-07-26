{
  lib,
  buildNpmPackage,
  callPackage,
  src,
  sourceRelease,
  cli,
  jsNative ? callPackage ./js-runtime-native.nix {
    inherit src sourceRelease;
  },
}:
buildNpmPackage {
  pname = "encore-runtime-js";
  version = sourceRelease.version;
  inherit src;

  sourceRoot = "${src.name}/runtimes/js/encore.dev";
  npmDepsHash = sourceRelease.npmDepsHash;

  nativeBuildInputs = [ cli ];

  preBuild = ''
    mkdir -p internal/runtime/napi
    encore-napi-defs \
      -version "v${sourceRelease.version}" \
      -input ${jsNative}/share/encore/typedefs.ndjson \
      -dts-output internal/runtime/napi/napi.d.cts \
      -cjs-output internal/runtime/napi/napi.cjs
  '';

  postBuild = ''
    ./node_modules/.bin/tsc-esm-fix --target=dist
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/runtimes
    cp -r ${src}/runtimes/js $out/runtimes/
    chmod -R u+w $out/runtimes/js
    rm -rf $out/runtimes/js/encore.dev/dist
    cp -r dist $out/runtimes/js/encore.dev/
    mkdir -p $out/runtimes/js/encore.dev/internal/runtime
    cp -r internal/runtime/napi $out/runtimes/js/encore.dev/internal/runtime/
    cp ${jsNative}/lib/encore-runtime.node $out/runtimes/js/

    runHook postInstall
  '';

  passthru = {
    inherit jsNative;
  };

  meta = {
    description = "Encore JavaScript runtime";
    homepage = "https://encore.dev";
    license = lib.licenses.mpl20;
  };
}
