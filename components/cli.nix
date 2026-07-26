{
  lib,
  buildGoModule,
  src,
  sourceRelease,
}:
buildGoModule {
  pname = "encore-cli";
  version = sourceRelease.version;
  inherit src;

  vendorHash = sourceRelease.vendorHash;

  postPatch = ''
    mkdir -p cmd/encore-napi-defs
    cp ${./generate-napi-defs.go} cmd/encore-napi-defs/main.go
  '';

  subPackages = [
    "cli/cmd/encore"
    "cli/cmd/git-remote-encore"
    "cli/cmd/tsbundler-encore"
    "cmd/encore-napi-defs"
  ];

  tags = [ "netgo" ];

  ldflags = [
    "-s"
    "-w"
    "-X=encr.dev/internal/version.Version=v${sourceRelease.version}"
  ];

  doCheck = false;

  meta = {
    description = "Encore command-line binaries";
    homepage = "https://encore.dev";
    license = lib.licenses.mpl20;
    mainProgram = "encore";
  };
}
