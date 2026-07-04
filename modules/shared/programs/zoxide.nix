{
  # Zoxide: smarter cd (replaces `eval "$(zoxide init --cmd cd zsh)"`)
  programs.zoxide = {
    enable = true;
    options = [ "--cmd" "cd" ];
  };
}
