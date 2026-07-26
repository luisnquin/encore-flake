{
  lib,
  stdenvNoCC,
  applyPatches,
  fetchFromGitHub,
  callPackage,
  sourceRelease ? import ./source-release.nix,
  encoreSrc ? fetchFromGitHub {
    owner = "encoredev";
    repo = "encore";
    rev = "v${sourceRelease.version}";
    hash = sourceRelease.sourceHash;
  },
  patches ? [ ],
  patchedSrc ? applyPatches {
    name = "encore-${sourceRelease.version}-source";
    src = encoreSrc;
    inherit patches;
  },
  cli ? callPackage ./components/cli.nix {
    src = patchedSrc;
    inherit sourceRelease;
  },
  tsparser ? callPackage ./components/tsparser.nix {
    src = patchedSrc;
    inherit sourceRelease;
  },
  runtimeGo ? callPackage ./components/runtime-go.nix {
    src = patchedSrc;
    inherit sourceRelease;
  },
  runtimeJs ? callPackage ./components/runtime-js.nix {
    src = patchedSrc;
    inherit sourceRelease cli;
  },
  encoreGo ? callPackage ./components/encore-go.nix {
    inherit sourceRelease;
  },
}:
stdenvNoCC.mkDerivation {
  pname = "encore";
  version = sourceRelease.version;

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/runtimes
    cp ${cli}/bin/encore $out/bin/
    cp ${cli}/bin/git-remote-encore $out/bin/
    cp ${cli}/bin/tsbundler-encore $out/bin/
    cp ${tsparser}/bin/tsparser-encore $out/bin/
    cp -r ${runtimeGo}/runtimes/go $out/runtimes/
    cp -r ${runtimeJs}/runtimes/js $out/runtimes/
    cp -r ${encoreGo}/encore-go $out/

    runHook postInstall
  '';

  passthru = {
    inherit encoreSrc patchedSrc;
    components = {
      inherit
        cli
        tsparser
        runtimeGo
        runtimeJs
        encoreGo
        ;
    };
  };

  meta = {
    description = "Encore CLI built from source";
    homepage = "https://encore.dev";
    license = lib.licenses.mpl20;
    mainProgram = "encore";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
