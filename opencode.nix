{
  pkgs,
  ...
}:
{
  # Enable OpenCode AI coding assistant
  programs.opencode = {
    enable = true;

    # Enable built-in LSP support
    settings = {
      lsp = true;

      # OpenRouter as the LLM provider
      provider.openrouter = { };
    };

    # Catppuccin Mocha theme for the TUI
    tui = {
      theme = "catppuccin";
    };
  };
}
