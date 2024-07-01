# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModule

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  # Set your username
  home = {
    username = "brine";
    homeDirectory = "/home/brine";
  };

  # Install user level packages with Nix
  home.packages = with pkgs; [
    ani-cli
    bat
    dipc
    fastfetch
    fzf
    lsd
    onefetch
    ueberzugpp
    yazi
    ytfzf
    zellij
    zoxide
  ];

  # Create symlinks for dotfiles
  home.file = {
    # Shell/CLI config
    ".zshrc".source = ./home/.zshrc;
    ".p10k.zsh".source = ./home/.p10k.zsh;
    ".miniplug.zsh".source = ./home/.miniplug.zsh;
    ".config/bat".source = ./config/bat;
    ".config/fsh".source = ./config/fsh;
    ".config/zellij".source = ./config/zellij;
    ".config/yazi".source = ./config/yazi;
    # Theme config
    #".themes/catppuccin-mocha-lavender-standard+default".source = ./gnome/themes/catppuccin-mocha-lavender-standard+default;
    #".themes/catppuccin-mocha-lavender-standard+default-hdpi".source = ./gnome/themes/catppuccin-mocha-lavender-standard+default-hdpi;
    #".themes/catppuccin-mocha-lavender-standard+default-xhdpi".source = ./gnome/themes/catppuccin-mocha-lavender-standard+default-xhdpi;
    #".icons/catppuccin-mocha-dark-cursors".source = ./gnome/icons/catppuccin-mocha-dark-cursors;
    #".icons/papirus-folders".source = ./gnome/icons/papirus-folders;
    # The icons and themes files do not seem to be registered by flatpaks if they are symlinked.
    ".config/gtk-4.0/assets".source = ./gnome/themes/catppuccin-mocha-lavender-standard+default/gtk-4.0/assets;
    ".config/gtk-4.0/gtk-dark.css".source = ./gnome/themes/catppuccin-mocha-lavender-standard+default/gtk-4.0/gtk-dark.css;
    ".config/gtk-4.0/gtk.css".source = ./gnome/themes/catppuccin-mocha-lavender-standard+default/gtk-4.0/gtk.css;
  };

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  # home.packages = with pkgs; [ steam ];

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";
}
