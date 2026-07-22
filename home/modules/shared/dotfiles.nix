{
  # Symlinked raw dotfiles
  home.file = {
    ".p10k.zsh".source = ./dotfiles/.p10k.zsh;
    ".config/fsh".source = ./dotfiles/.config/fsh;
    ".hermes/skins/catppuccin.yaml".source = ./dotfiles/.hermes/skins/catppuccin.yaml;
    ".hermes/plugins/web/local".source = ./dotfiles/.hermes/plugins/web/local;

    # Agent-only commit wrapper. Appends the Generated-By trailer that
    # SOUL.md requires, using the running Hermes version. Plain `git commit`
    # (used by the human) is untouched. executable = true keeps the bit set
    # across HM rebuilds; Nix store paths are read-only otherwise.
    ".local/bin/gc-hermes" = {
      source = ./scripts/gc-hermes;
      executable = true;
    };
  };
}
