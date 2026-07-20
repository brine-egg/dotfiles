{
  pkgs,
  inputs,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
  # HERMES_HOME: where Hermes writes its runtime state. The default profile
  # is ~/.hermes; this path is used to compute an absolute shared_surface
  # path so the Mnemosyne plugin (which uses Python's Path.expanduser — only
  # honors "~", not "$HOME") receives a fully-resolved string.
  hermesHome = "/home/brine/.hermes";

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

  # Mnemosyne memory layer (mnemosyne-memory core + mnemosyne-hermes plugin
  # wrapper). Built against numtide's Python 3.14 — same interpreter hermes-agent
  # runs under — so both packages are importable in the CLI and gateway envs.
  # See ./mnemosyne.nix for the dependency rationale and how to switch from
  # local embeddings to a remote embedding API.
  mnemosyne = numtidePkgs.callPackage ./mnemosyne.nix { };

  hermesAgent = numtidePkgs.callPackage ./hermes-agent-package.nix {
    extraPythonPackages = [
      numtidePythonPackages.ddgs
      numtidePythonPackages.html2text
      mnemosyne.mnemosyne-memory
      mnemosyne.mnemosyne-hermes
    ];
  };
in
{
  programs.hermes-agent = {
    enable = true;
    package = hermesAgent;
    extraPlugins = [
      (pkgs.fetchFromGitHub {
        owner = "stephenschoettler";
        repo = "hermes-lcm";
        rev = "v0.19.0";
        hash = "sha256-B80HCn3BT+M1B8THMm3Ph5tpimTB68yIVkBfPaV4X40=";
      })
      mnemosyne.mnemosyne-hermes-plugin-dir
    ];
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
      context.engine = "lcm";
      memory = {
        # Provider name must match the plugin directory name in ~/.hermes/plugins/.
        # The HM extraPlugins activation creates nix-managed-<getName> symlinks,
        # so the provider name is "nix-managed-mnemosyne" (getName of the
        # runCommandLocal "mnemosyne" derivation in mnemosyne.nix).
        provider = "nix-managed-mnemosyne";
        memory_enabled = false;
        user_profile_enabled = false;
        # Per-profile memory isolation: each Hermes profile gets its own SQLite
        # bank under mnemosyne/data/banks/<profile>/mnemosyne.db instead of the
        # shared default bank. The default profile (hermes_home basename
        # ".hermes") falls back to the "default" bank — same path as before.
        #
        # shared_surface_path is fully expanded at Nix eval time using the
        # `hermesHome` constant from the let block. The Mnemosyne plugin's
        # Path.expanduser() only honors "~", not "$HOME", so we resolve it
        # to an absolute path here. The perihelion profile uses the same
        # path via its unversioned config.yaml.
        mnemosyne = {
          profile_isolation = true;
          shared_surface_path = "${hermesHome}/mnemosyne/data/shared/mnemosyne.db";
          shared_surface_read = true;
        };
      };
      plugins.enabled = [
        "web-local"
        # "hermes-vcc"
        "hermes-lcm"
        "rtk-rewrite"
      ];
      agent = {
        disabled_toolsets = [
          "x_search"
        ];
        # Explicit reasoning effort so providers can't silently downgrade under
        # load (seen with StreamLake on GLM-5.2). Bump per-session with
        # `hermes config set agent.reasoning_effort high` when needed.
        reasoning_effort = "medium";
        system_prompt = ''
          ## Operational rules — hard constraints, override only with explicit permission

          - Do not edit unversion-controlled code or config without Brine's explicit permission.
          - Do not commit until the code has compiled and been verified by running it — not just by reading it.
          - Do not rely on guesswork when you are missing information needed to proceed. Search documentation, or ask Brine — do not begin work until you have what you need.
          - Always use conventional commit format, unless Brine states otherwise.
          - Every commit must contain the trailer `Generated-By: Hermes Agent v<version>`. Use `gc-hermes` instead of `git commit` — it extracts the version and appends the trailer automatically. If `gc-hermes` is unavailable, fall back to `hermes --version` + `git commit --trailer "Generated-By: Hermes Agent v<version>"`. If `hermes --version` also fails, ask Brine for the version number rather than substituting a placeholder.

          ## Suggestions — defaults you should follow unless context argues against them

          - If an instruction is too vague, ask Brine to expand upon it.
          - Prioritise long-term maintainability and scalability over band-aid solutions.
          - If a task seems infeasible or too complex, suggest an alternative approach.
          - Make only changes necessary for the current goal.
        '';
      };
      # CLI (TUI) clarify prompts block the agent for a response. The default
      # is 120s, which fires while the user is still reading. Raise to a very
      # large value (≈115 days) so the prompt stays open until answered. This
      # only affects the CLI; gateway clarify uses agent.clarify_timeout.
      clarify.timeout = 9999999;
    };
  };
}
