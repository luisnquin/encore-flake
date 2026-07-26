{
  description = "nix flake that packages Encore from source and released binaries";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  outputs =
    { self
    , nixpkgs
    ,
    }:
    let
      eachSystem = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
    in
    {
      packages = eachSystem (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          encoreBin = pkgs.callPackage ./encore-bin.nix { };
          encore = pkgs.callPackage ./encore.nix { };
        in
        {
          inherit encore;
          encore-bin = encoreBin;
          encore-cli = encore.components.cli;
          encore-tsparser = encore.components.tsparser;
          encore-runtime-go = encore.components.runtimeGo;
          encore-runtime-js = encore.components.runtimeJs;
          encore-go = encore.components.encoreGo;
          default = encore;
        });

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;

      homeModules.default = { pkgs, ... } @ args:
        import ./hm-module.nix ({
          encore = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
        }
        // args);
    };
}
