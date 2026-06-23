{
  description = "Home Manager flake for personal dotfiles";

  inputs = {
    # Nixpkgs and Home Manager
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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
      # Shared modules used on both platforms
      sharedModules = [
        ./home.nix
        ./opencode.nix
        ./packages/shared.nix
        ./dotfiles/shared.nix
        catppuccin.homeModules.catppuccin
      ];

      # Helper to build a Home Manager configuration for a given system
      mkHome = system: osModules:
        let
          pkgs = import nixpkgs {
            inherit system;
            # nixGL overlay only needed on Linux
            overlays = nixpkgs.lib.optionals (system == "x86_64-linux") [ nixgl.overlay ];
          };
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = sharedModules ++ osModules;
        };
    in {
      # AMD64 Linux
      homeConfigurations."brine" = mkHome "x86_64-linux" [
        ./packages/linux.nix
        ./dotfiles/linux.nix
      ];

      # ARM64 macOS
      homeConfigurations."brine-darwin" = mkHome "aarch64-darwin" [
        ./packages/darwin.nix
        ./dotfiles/darwin.nix
      ];
    };
}
