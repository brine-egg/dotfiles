{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:/nix-community/home-manager/";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    jerry = { 
      url ="github:justchokingaround/jerry";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, jerry, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      homeConfigurations."brine" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ 
          ./home.nix
          {
            home.packages = [ jerry.packages.${system}.full ];
          }
        ];
      };
    };
}
