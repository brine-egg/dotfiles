{
  pkgs,
  inputs,
  lib,
  ...
}:
{
  programs.agent-skills = {
    enable = true;

    # ------------------------------------------------------------------
    # Sources
    # ------------------------------------------------------------------
    # Each path input is a flake=false git source whose layout is just
    # `skills/<skill>/SKILL.md` (anthropic, juliusbrussee) or
    # `skills/<category>/<skill>/SKILL.md` (mattpocock). `idPrefix` namespaced
    # to prevent collisions across sources (the README is explicit: when two
    # sources can expose the same relative path, prefix them).
    sources = {
      # anthropic-skills = {
      #   input = "anthropic-skills";
      #   subdir = "skills";
      # };

      # juliusbrussee-skills = {
      #   input = "juliusbrussee-skills";
      #   subdir = "skills";
      #   idPrefix = "juliusbrussee";
      #   # JuliusBrussee's skills are flat (one level under skills/).
      #   filter.maxDepth = 1;
      # };

      mattpocock-skills = {
        input = "mattpocock-skills";
        subdir = "skills";
        idPrefix = "mattpocock";
        # mattpocock's skills are nested under category dirs
        # (engineering/, productivity/, ...). Default maxDepth = null is
        # correct here.
      };

      nixos-ai-skill = {
        input = "nixos-ai-skill";
        subdir = ".";
        idPrefix = "nixos";
      };
    };

    # ------------------------------------------------------------------
    # Allowlist
    # ------------------------------------------------------------------
    skills.enable = [
      # Hub-tracked skills reinstalled from canonical sources.
      # IDs are namespaced because we set idPrefix on the source.
      "mattpocock/productivity/grilling"
      "mattpocock/engineering/grill-with-docs"
      "mattpocock/engineering/domain-modeling"
      "mattpocock/engineering/codebase-design"
      "mattpocock/engineering/improve-codebase-architecture"
      "mattpocock/engineering/research"
      "mattpocock/productivity/teach"
      "nixos/nixos-ai-skill"
    ];

    # ------------------------------------------------------------------
    # Target
    # ------------------------------------------------------------------
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

    # ------------------------------------------------------------------
    # Excludes
    # ------------------------------------------------------------------
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
