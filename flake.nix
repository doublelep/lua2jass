{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";

    pjass.url = "github:lep/pjass";
    pjass.inputs.nixpkgs.follows = "nixpkgs";
    pjass.inputs.systems.follows = "systems";
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
