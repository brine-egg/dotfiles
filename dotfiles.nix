{
  inputs,
  lib,
  config,
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

  gtk = {
    enable = true;
    theme.package = pkgs.catppuccin-gtk;
    cursorTheme.package = pkgs.catppuccin-cursors;
    theme.name = "catppuccin-mocha-lavender-standard+default";
    cursorTheme.name = "catppuccin-mocha-dark-cursors";
  };

}
