{
  pkgs,
  ...
}: {

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
  };

  # Set themes
  gtk = {
    enable = true;
    theme = {
      name = "catppuccin-mocha-lavender-standard+default";
      package = pkgs.catppuccin-gtk;
    };
    cursorTheme = {
      name = "catppuccin-mocha-dark-cursors";
      package = pkgs.catppuccin-cursors;
    };
  };

}
