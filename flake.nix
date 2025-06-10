{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
    # flake-utils.url = "github:numtide/flake-utils";

    pjass.url = "github:lep/pjass";
    pjass.inputs.nixpkgs.follows = "nixpkgs";
    pjass.inputs.systems.follows = "systems";
    # pjass.inputs.flake-utils.follows = "flake-utils";

    # common-j.url = "github:lep/common-j";
    # common-j.inputs.nixpkgs.follows = "nixpkgs";
    # common-j.inputs.flake-utils.follows = "flake-utils";

    # wc3.url = "git+file:/Users/lep/dev/wc3-mapping";
    # wc3.inputs.nixpkgs.follows = "nixpkgs";
    # wc3.inputs.flake-utils.follows = "flake-utils";
    # wc3.inputs.common-j.follows = "common-j";
  };

  outputs = { nixpkgs, systems, pjass, ... }:
    let
      eachSystem = nixpkgs.lib.genAttrs (import systems);
      lua2jass = pkgs: pkgs.haskellPackages.callPackage ./lua2jass.nix { };
    in {
      packages = eachSystem (system:
        let pkgs = import nixpkgs { inherit system; };
        in { default = lua2jass pkgs; });
      devShells = eachSystem (system:
        let
          pkgs = import nixpkgs { inherit system; };
          pjass-drv = pjass.packages.${system}.pjass;
          # wc3-drv = wc3.packages.${system};
        in {
          default = pkgs.mkShell {
            buildInputs = [
              pkgs.cabal-install
              pjass-drv
              # wc3-drv.jhcr-start
              # wc3-drv.jhcr-update
              # wc3-drv.wc3
            ];
          };
        });
    };
}
