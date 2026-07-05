{
  # OpenAI Codex CLI using OpenRouter as the model provider.
  # API key is NOT stored here; export OPENROUTER_API_KEY manually in your shell.
  programs.codex = {
    enable = true;
    settings = {
      model = "z-ai/glm-5.2";
      model_provider = "openrouter";
      model_providers.openrouter = {
        name = "OpenRouter";
        base_url = "https://openrouter.ai/api/v1";
        env_key = "OPENROUTER_API_KEY";
        wire_api = "chat";
      };
    };
  };
}