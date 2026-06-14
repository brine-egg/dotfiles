{
  description = "Home Manager flake for personal dotfiles";

  inputs = {
    # Nixpkgs and Home Manager
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # nixGL for GPU-accelerated apps on non-NixOS
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Catppuccin theme for supported programs
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, nixgl, catppuccin, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      # Home Manager configuration for user "brine"
      homeConfigurations."brine" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [
          ./home.nix        # Core Home Manager settings
          ./packages.nix    # User packages to install
          ./dotfiles.nix    # Program configs and dotfile symlinks
          catppuccin.homeManagerModules.catppuccin
        ];
      };
    };
}
