{
  description = "Extremely scuffed Home Manager flake";

  inputs = {

    # Input basic repos
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:/nix-community/home-manager/";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nixGL repo, provides workaround for OpenGL dependent packages
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Jerry (anime CLI tool) repo, containing HM module
    jerry = { 
      url ="github:justchokingaround/jerry";
      inputs.nixpkgs.follows = "nixpkgs";

    };
  };

  outputs = { nixpkgs, home-manager, jerry, nixgl, ... }:
    let

      # Basic variables
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      # Overlay packages
      overlays = [
        nixgl.overlay ];


    in {
      homeConfigurations."brine" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Load HM modules
        modules = [ 
          ./home.nix

          { # Flake packages
            home.packages = [ 
              jerry.packages.${system}.full 
            ];
          }

        ];

      };
    };
}
