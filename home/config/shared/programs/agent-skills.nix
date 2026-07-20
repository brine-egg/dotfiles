{
  pkgs,
  inputs,
  lib,
  ...
}:
{
  programs.agent-skills = {
    enable = true;

    # Path-input source: anthropics/skills has no flake outputs, just files under
    # `skills/`. `subdir = "skills"` scopes discovery to that directory.
    sources.anthropic-skills = {
      input = "anthropic-skills";
      subdir = "skills";
    };

    # Allowlist of skill IDs. Discovered IDs are the subdirectory names under
    # anthropics/skills/skills/ (with `filter.maxDepth = null` they are flat —
    # each skill is a single subdir containing SKILL.md). Confirmed via
    # GitHub Contents API on anthropics/skills main branch.
    skills.enable = [
      "algorithmic-art"
      "brand-guidelines"
      "canvas-design"
      "claude-api"
      "doc-coauthoring"
      "docx"
      "frontend-design"
      "internal-comms"
      "mcp-builder"
      "pdf"
      "pptx"
      "skill-creator"
      "slack-gif-creator"
      "theme-factory"
      "web-artifacts-builder"
      "webapp-testing"
      "xlsx"
    ];

    # Hermes is not in agent-skills defaultTargets, so we must set dest
    # explicitly. `structure = "symlink-tree"` (default) supports shell
    # variable expansion at activation time — $HOME resolves at runtime.
    # `link` structure does NOT support $HOME and would error.
    #
    # `dest` points at a `nix-managed/` subdirectory under
    # ~/.hermes/skills, NOT the skills root itself. Hermes recursively
    # scans ~/.hermes/skills/ for any directory containing SKILL.md, so
    # skills installed under nix-managed/ are still discovered and listed
    # as `local` source. This keeps the module's rsync --delete scoped
    # to its own slice — Hermes-installed skills (under their own
    # category paths) coexist without conflict.
    #
    # ~/.hermes/profiles/hermes-perihelion/skills is a symlink to
    # ~/.hermes/skills, so a single dest covers all profiles that opt in.
    targets.hermes = {
      enable = true;
      dest = "$HOME/.hermes/skills/nix-managed";
      structure = "symlink-tree";
    };

    # Default is [ ".system" ]. Override to:
    # - keep .archive/ and .hub/ (Hermes runtime subdirs under
    #   ~/.hermes/skills/) — defensive; they live at the parent level of
    #   dest, so rsync cannot touch them in practice, but listing them
    #   here means a future dest change cannot accidentally clobber them
    # - keep Hermes runtime state files (.bundled_manifest, .usage.json,
    #   .curator_state, ...) via the `.*` and `*~` patterns
    excludePatterns = [
      ".archive"
      ".hub"
      ".*"
      "*~"
    ];
  };
}
