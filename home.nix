# Original config file from https://github.com/Misterio77/nix-starter-configs
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {

  # You can import other home-manager modules here
  imports = [
    # E.g. inputs.nix-colors.homeManagerModule
  ];

  nixpkgs = {

    # You can add overlays here
    overlays = [
      # E.g. neovim-nightly-overlay.overlays.default
    ];

    # Configure your nixpkgs instance
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };

  # Set your username
  home = {
    username = "brine";
    homeDirectory = "/home/brine";
  };

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";
}
