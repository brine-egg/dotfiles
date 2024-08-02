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

  # Install user level packages with Nix
  home.packages = with pkgs; [
    bat
    dipc
    fastfetch
    fzf
    lsd
    nh
    onefetch
    ripgrep
    spicetify-cli
    trashy
    tmux
    ueberzugpp
    w3m
    yazi
    ytfzf
    zoxide
  ];

  # Create symlinks for dotfiles
  home.file = {

    # Shell/CLI config
    ".zshrc".source = ./home/.zshrc;
    ".p10k.zsh".source = ./home/.p10k.zsh;
    ".miniplug.zsh".source = ./home/.miniplug.zsh;
    ".config/bat".source = ./config/bat;
    ".config/fastfetch".source = ./config/fastfetch;
    ".config/fsh".source = ./config/fsh;
    ".config/yazi".source = ./config/yazi;
    ".config/tmux/tmux.conf".source = ./config/tmux/tmux.conf;

    # Theme config
    # The icons and themes files do not seem to be registered by flatpaks if they are symlinked, so they need to be manually copied into a separate directory.
    ".local/share/themes/catppuccin-mocha-lavender-standard+default".source = ./gnome/themes/catppuccin-mocha-lavender-standard+default;
    ".local/share/themes/catppuccin-mocha-lavender-standard+default-hdpi".source = ./gnome/themes/catppuccin-mocha-lavender-standard+default-hdpi;
    ".local/share/themes/catppuccin-mocha-lavender-standard+default-xhdpi".source = ./gnome/themes/catppuccin-mocha-lavender-standard+default-xhdpi;
    ".local/share/icons/catppuccin-mocha-dark-cursors".source = ./gnome/icons/catppuccin-mocha-dark-cursors;
    ".local/share/icons/papirus-folders".source = ./gnome/icons/papirus-folders;
    ".config/gtk-4.0/assets".source = ./gnome/themes/catppuccin-mocha-lavender-standard+default/gtk-4.0/assets;
    ".config/gtk-4.0/gtk-dark.css".source = ./gnome/themes/catppuccin-mocha-lavender-standard+default/gtk-4.0/gtk-dark.css;
    ".config/gtk-4.0/gtk.css".source = ./gnome/themes/catppuccin-mocha-lavender-standard+default/gtk-4.0/gtk.css;

  };

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";
}
