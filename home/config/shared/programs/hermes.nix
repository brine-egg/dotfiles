{
  pkgs,
  inputs,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;

  # The hermes-home.nix HM module only ships the module, not the package. The
  # package lives in numtide/llm-agents.nix. numtide's packaging has a CLOSED
  # callPackage arg list (no extraPythonPackages/.override support), so we
  # vendor its package.nix (./hermes-agent-package.nix) with one change:
  # `extraPythonPackages` is spliced into `hermesDeps`. That single list feeds
  # both the `hermes` CLI env (dependencies) AND the HERMES_PYTHON gateway env
  # (pythonEnv = python3.withPackages (_: hermesDeps)), so ddgs/html2text are
  # importable regardless of which python runs the web-search tool.
  #
  # Unlike the upstream NousResearch flake (uv2nix sealed venv with a build-time
  # collision guard that aborts on shared transitive deps like ddgs->click),
  # `python3.withPackages` dedups by canonical name — collision-free.
  #
  # CRITICAL interpreter match: callPackage against numtide's OWN nixpkgs
  # (inputs.llm-agents.inputs.nixpkgs), not this flake's `pkgs`. numtide built
  # hermes-agent against that exact python3 (3.14) and pins the same nixpkgs in
  # its lock, so (a) the base package + hermes-frontend npm build hit the
  # numtide binary cache, and (b) ddgs/html2text come from the matching
  # python3Packages — a different nixpkgs' python3 wheels are not
  # cross-interpreter importable.
  numtidePkgs = inputs.llm-agents.inputs.nixpkgs.legacyPackages.${system};
  numtidePythonPackages = numtidePkgs.python3Packages;

  hermesAgent = numtidePkgs.callPackage ./hermes-agent-package.nix {
    extraPythonPackages = [
      numtidePythonPackages.ddgs
      numtidePythonPackages.html2text
    ];
  };
in
{
  programs.hermes-agent = {
    enable = true;
    package = hermesAgent;
    settings = {
      providers = [ "openrouter" ];
      model = "xiaomi/mimo-v2.5-pro";
      terminal.backend = "local";
      display = {
        interface = "tui";
        skin = "catppuccin";
      };
      web = {
        search_backend = "ddgs";
        extract_backend = "local";
      };
      context.engine = "vcc";
      plugins.enabled = [
        "web-local"
        "hermes-vcc"
        "rtk-rewrite"
      ];
      agent.disabled_toolsets = [
        "x_search"
      ];
    };
  };
}
