{

  description = "Extremely scuffed Home Manager flake";

  inputs = {
    # Input basic repos
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:/nix-community/home-manager/";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nixGL repo, provides workaround for OpenGL dependent packages
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Catppuccin colour scheme repo
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, nixgl, catppuccin, ... }:
    let
      # Basic variables
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      # Overlay packages
      overlays = [
        nixgl.overlay
      ];

    in {
      homeConfigurations."brine" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Load modules
        modules = [ 
          ./home.nix
          ./packages.nix
          ./dotfiles.nix
          catppuccin.homeManagerModules.catppuccin
        ];
      };
    };

}
