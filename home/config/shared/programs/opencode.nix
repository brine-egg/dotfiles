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

    context = ''
      		When making a git commit, end the commit message with the following two trailers so OpenCode is credited:

      		Generated with [opencode](https://opencode.ai)

      		Co-Authored-By: opencode <noreply@opencode.ai>

      		Use the repository's git config for the primary author (do not override `--author`).
      	'';

    # Catppuccin Mocha theme for the TUI
    tui = {
      theme = "catppuccin";
    };
  };
}
