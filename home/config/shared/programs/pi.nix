{
  programs.pi-coding-agent = {
    enable = true;
    settings = {
      defaultProvider = "openrouter";
      defaultModel = "deepseek/deepseek-v4-flash";
      defaultThinkingLevel = "medium";
    };
  };
}
