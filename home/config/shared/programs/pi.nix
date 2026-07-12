{
  programs.pi-coding-agent = {
    enable = true;
    settings = {
      defaultProvider = "openrouter";
      defaultModel = "minimax/minimax-m3";
      defaultThinkingLevel = "medium";
      theme = "catppuccin-mocha-lavender";
      packages = [
        "git:github.com/XYenon/catppuccin-pi-coding-agent"
        "npm:@aliou/pi-guardrails"
        "npm:pi-co-authored-by"
        "npm:pi-web-access"
        "npm:pi-lens"
      ];
      enableInstallTelemetry = true;
    };
  };

  home.sessionVariables = {
    PI_TELEMETRY = "1";
  };

  # Manage pi-guardrails global config
  home.file.".pi/agent/extensions/guardrails.json" = {
    text = builtins.toJSON {
      "$schema" = "https://unpkg.com/@aliou/pi-guardrails@0.15.0/schema.json";
      applyBuiltinDefaults = true;
      version = "0.13.0-20260619";
      onboarding = {
        completed = true;
        completedAt = "2026-07-12T12:09:25.495Z";
        version = "0.13.0-20260619";
      };
      features = {
        pathAccess = true;
      };
      pathAccess = {
        mode = "ask";
        allowedPaths = [
          {
            kind = "file";
            path = "/dev/null";
          }
        ];
      };
    };
  };
}
