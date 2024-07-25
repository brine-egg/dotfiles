{
  description = "Extremely scuffed Home Manager flake";

  inputs = {
    # Nixpkgs repo
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # Home Manager itself
    home-manager = {
      url = "github:/nix-community/home-manager/";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Jerry (anime CLI tool) repo, containing HM module
    jerry = { 
      url ="github:justchokingaround/jerry";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, jerry, ... }:
    let
      # Basic convenience variables
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      homeConfigurations."brine" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        # Load HM modules
        modules = [ 
          ./home.nix
          {
            home.packages = [ jerry.packages.${system}.full ];
          }
        ];
      };
    };
}
