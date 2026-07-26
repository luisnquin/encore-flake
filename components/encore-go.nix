{
  lib,
  fetchFromGitHub,
  fetchurl,
  go_1_26,
  sourceRelease,
  encoreGoSrc ? fetchFromGitHub {
    owner = "encoredev";
    repo = "go";
    rev = sourceRelease.encoreGo.rev;
    hash = sourceRelease.encoreGo.sourceHash;
  },
  goSrc ? fetchurl {
    url = "https://go.dev/dl/go${sourceRelease.encoreGo.version}.src.tar.gz";
    hash = sourceRelease.encoreGo.goSourceHash;
  },
}:
(go_1_26.overrideAttrs (old: {
  pname = "encore-go";
  version = "${sourceRelease.encoreGo.version}-encore";
  src = goSrc;

  patches = (old.patches or [ ]) ++ [
    "${encoreGoSrc}/patches/cover_patch.diff"
    "${encoreGoSrc}/patches/net_patch.diff"
    "${encoreGoSrc}/patches/runtime_patch.diff"
    "${encoreGoSrc}/patches/testing_patch.diff"
    "${encoreGoSrc}/patches/version_patch.diff"
  ];

  postPatch = (old.postPatch or "") + ''
    cp -R ${encoreGoSrc}/overlay/. .
    chmod -R u+w .
  '';

  env = (old.env or { }) // {
    CGO_ENABLED = 0;
    GOROOT_FINAL = "/encore";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/encore-go $out/bin
    cp -a bin pkg src lib misc api doc go.env VERSION $out/encore-go
    ln -s ../encore-go/bin/go $out/bin/go

    runHook postInstall
  '';

  passthru = (old.passthru or { }) // {
    inherit encoreGoSrc goSrc;
  };

  meta = old.meta // {
    description = "Encore Go toolchain built from source";
    homepage = "https://github.com/encoredev/go";
    license = lib.licenses.bsd3;
    mainProgram = "go";
  };
}))
