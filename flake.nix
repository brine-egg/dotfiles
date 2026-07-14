{
  description = "NixOS, nix-darwin, and Home Manager flake for personal dotfiles";

  inputs = {
    # Nixpkgs shared across all outputs
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Determinate Nix module
    determinate.url = "github:DeterminateSystems/determinate";

    # Home Manager (standalone)
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nixGL for GPU-accelerated apps on non-NixOS Linux
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Catppuccin theme for supported programs
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nix-darwin for macOS system configuration
    darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # mac-app-util: Spotlight-indexed .app trampolines for Nix-installed GUI apps on macOS
    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs.nixpkgs.follows = "nixpkgs";
    };

	# Home Manager module for Hermes Agent
    hermes-home = {
      url = "github:urchin-tidebot/hermes-home.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Provides the `hermes-agent` package itself. Consumed directly via
    # inputs.llm-agents.packages.${system}.hermes-agent so it builds against
    # this flake's pinned nixpkgs-unstable and hits the numtide binary cache.
    # Do NOT add inputs.nixpkgs.follows here: upstream is only built/tested
    # against its own nixpkgs-unstable and following ours risks build failures.
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
    };
  };

  outputs =
    {
      nixpkgs,
      determinate,
      home-manager,
      nixgl,
      catppuccin,
      darwin,
      mac-app-util,
      hermes-home,
      ...
    }@inputs:
    let
      # -----------------------------------------------------------------
      # Home Manager (standalone) — used on non-NixOS Linux and macOS
      # -----------------------------------------------------------------
      sharedModules = [
        ./home/home.nix
        ./home/config/shared
        ./home/packages/shared.nix
        catppuccin.homeModules.catppuccin
        hermes-home.homeManagerModules.default
      ];

      mkHome =
        system: osModules:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = nixpkgs.lib.optionals (system == "x86_64-linux") [ nixgl.overlay ];
          };
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = sharedModules ++ osModules;
          extraSpecialArgs = { inherit inputs; };
        };

      # -----------------------------------------------------------------
      # NixOS system configuration
      # -----------------------------------------------------------------
      mkNixos =
        system: hostname: extraModules:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/${hostname}/hardware.nix
            ./nixos/config
            ./nixos/packages/common.nix
            ./hosts/${hostname}/default.nix
          ]
          ++ extraModules;
        };

      # -----------------------------------------------------------------
      # nix-darwin system configuration
      # -----------------------------------------------------------------
      mkDarwin =
        system: hostname: extraModules:
        darwin.lib.darwinSystem {
          inherit system;
          modules = [
            mac-app-util.darwinModules.default
            ./darwin/config
            ./hosts/${hostname}/darwin.nix
          ]
          ++ extraModules;
        };
    in
    {
      # --- Home Manager (standalone) ---
      homeConfigurations."brine" = mkHome "x86_64-linux" [
        ./home/packages/linux.nix
        ./home/config/linux
        determinate.homeManagerModules.default
      ];

      homeConfigurations."brine-darwin" = mkHome "aarch64-darwin" [
        ./home/packages/darwin.nix
        ./home/config/darwin
        determinate.homeManagerModules.default
        mac-app-util.homeManagerModules.default
      ];

      # --- NixOS hosts ---
      nixosConfigurations.desktop = mkNixos "x86_64-linux" "desktop" [ ];

      nixosConfigurations.laptop = mkNixos "x86_64-linux" "laptop" [ ];

      # --- nix-darwin hosts ---
      darwinConfigurations."macbook" = mkDarwin "aarch64-darwin" "macbook" [ ];
    };
}
