{
  programs.pi-coding-agent = {
    enable = true;
    settings = {
      defaultProvider = "openrouter";
      defaultModel = "deepseek/deepseek-v4-flash";
      defaultThinkingLevel = "medium";
      theme = "catppuccin-mocha-lavender";
      packages = [
        "git:github.com/XYenon/catppuccin-pi-coding-agent"
        "npm:pi-web-access"
        "npm:pi-lens"
      ];
    };
  };
}
