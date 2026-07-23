{
  pkgs,
  inputs,
  lib,
  ...
}:

# ============================================================================
# agent-skills: per-target skill selection
# ============================================================================
# Upstream `agent-skills-nix` (Kyure-A) builds ONE bundle per module instance
# and syncs that bundle to every enabled target. There is no per-target skill
# selection in upstream (confirmed by reading lib/default.nix and
# modules/common.nix).
#
# Two module instances are configured here:
#
#   1. `programs.agent-skills` (Hermes) -- uses the upstream HM module as-is.
#      One bundle for all Hermes skills, synced to `targets.hermes`. The
#      upstream's `lib.mkDefault` defaults for `defaultTargets.<name>.dest`
#      apply here automatically.
#
#   2. `programs.agent-skills-pi` (Pi) -- uses the local
#      `mkAgentSkillsInstance` factory from `./agent-skills-instance.nix`.
#      A second, independent bundle with a smaller skill allowlist. The
#      factory exists specifically to make this kind of per-harness split
#      cheap (one stanza per harness, no per-harness module boilerplate).
#
# Adding a third harness (Claude, Codex, OpenCode, ...): invoke
# `mkAgentSkillsInstance "<harness>"` with the harness's sources / skills /
# targets / excludePatterns, then add the returned module to `imports`.
# See `mkAgentSkillsInstance` in `./agent-skills-instance.nix` for the full
# contract.
# ----------------------------------------------------------------------------

let
  mkAgentSkillsInstance = import ./agent-skills-instance.nix { inherit pkgs inputs lib; };

  # -- Shared source declarations ------------------------------------------
  # Each path input is a flake=false git source whose layout is just
  # `skills/<skill>/SKILL.md` (anthropic, juliusbrussee) or
  # `skills/<category>/<skill>/SKILL.md` (mattpocock). `idPrefix` namespaced
  # to prevent collisions across sources (the README is explicit: when two
  # sources can expose the same relative path, prefix them).
  sharedSources = {
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

    ponytail-skills = {
      input = "ponytail-skills";
      subdir = "skills";
      idPrefix = "ponytail";
    };

    nixos-ai-skill = {
      input = "nixos-ai-skill";
      subdir = ".";
      idPrefix = "nixos";
    };
  };

  # -- Hermes skill set (full) ---------------------------------------------
  # All currently-enabled skills. Same as the pre-split configuration.
  hermesSkillAllow = [
    # Hub-tracked skills reinstalled from canonical sources.
    # IDs are namespaced because we set idPrefix on the source.
    "mattpocock/productivity/grilling"
    "mattpocock/engineering/grill-with-docs"
    "mattpocock/engineering/domain-modeling"
    "mattpocock/engineering/codebase-design"
    "mattpocock/engineering/improve-codebase-architecture"
    "mattpocock/engineering/resolving-merge-conflicts"
    "mattpocock/engineering/research"
    "mattpocock/productivity/teach"
    "nixos/nixos-ai-skill"
  ];

  # -- Pi skill set (reduced, agent-agnostic) -----------------------------
  # *** DEFAULT SUBSET -- adjust to taste. ***
  #
  # Pi is a separate coding agent (not Hermes) and runs in different
  # contexts (often a project checkout, not the dotfiles repo). Skills
  # that reference Nix, dotfiles, or Hermes-specific tooling (e.g. the
  # `nixos-ai-skill`, `domain-modeling`, `codebase-design`) assume
  # Nix-flake surroundings and would mislead Pi in non-Nix projects.
  #
  # The two skills kept here are pure interview/questioning primitives:
  #   - `mattpocock/productivity/grilling`     -- relentless
  #                                               interview/clarification
  #                                               skill
  #   - `mattpocock/engineering/grill-with-docs` -- same, grounded
  #                                                 against project
  #                                                 documentation
  # Both are agent-agnostic and do not assume a Nix/Hermes context.
  piSkillAllow = [
    "mattpocock/productivity/grilling"
    "mattpocock/engineering/grill-with-docs"
    "mattpocock/engineering/domain-modeling"
    "mattpocock/engineering/resolving-merge-conflicts"
    "ponytail/ponytail"
    "ponytail/ponytail-review"
    "ponytail/ponytail-audit"
    "nixos/nixos-ai-skill"
  ];

  # Command Code skill set
  cmdSkillAllow = [
    "mattpocock/productivity/grilling"
    "mattpocock/engineering/grill-with-docs"
    "mattpocock/engineering/domain-modeling"
    "mattpocock/engineering/resolving-merge-conflicts"
    "ponytail/ponytail"
    "ponytail/ponytail-review"
    "ponytail/ponytail-audit"
    "nixos/nixos-ai-skill"
  ];

  # -- Shared exclude patterns --------------------------------------------
  # Applied PER INSTANCE (rsync --exclude scope is the bundle root, not the
  # target root, so each instance's exclude list is independent). Default
  # is [ ".system" ] (the upstream value). We override to:
  # - keep .archive/ and .hub/ (Hermes runtime subdirs under
  #   ~/.hermes/skills/) -- defensive; they live at the parent level of
  #   dest, so rsync cannot touch them in practice, but listing them here
  #   means a future dest change cannot accidentally clobber them
  # - keep Hermes runtime state files (.bundled_manifest, .usage.json,
  #   .curator_state, ...) via the `.*` and `*~` patterns
  sharedExclude = [
    ".archive"
    ".hub"
    ".*"
    "*~"
  ];

  # -- Hermes target override ---------------------------------------------
  # Hermes is not in agent-skills defaultTargets, so we must set dest
  # explicitly. `structure = "symlink-tree"` (default) supports shell
  # variable expansion at activation time -- $HOME resolves at runtime.
  # `link` structure does NOT support $HOME and would error.
  #
  # `dest` points at a `nix-managed/` subdirectory under
  # ~/.hermes/skills, NOT the skills root itself. Hermes recursively
  # scans ~/.hermes/skills/ for any directory containing SKILL.md, so
  # skills installed under nix-managed/ are still discovered and listed
  # as `local` source. This keeps the module's rsync --delete scoped to
  # its own slice -- Hermes-installed skills (under their own category
  # paths) coexist without conflict.
  #
  # ~/.hermes/profiles/hermes-perihelion/skills is a symlink to
  # ~/.hermes/skills, so a single dest covers all profiles that opt in.
  hermesTarget = {
    enable = true;
    dest = "$HOME/.hermes/skills/nix-managed";
    structure = "symlink-tree";
  };
in
{
  imports = [
    # Pi instance: built from `mkAgentSkillsInstance`. Returns a self-
    # contained HM module that wires up `programs.agent-skills-pi` and
    # `home.activation.agent-skills-pi`. The upstream's
    # `defaultTargets.pi.dest` is filled in by the factory's internal
    # `lib.mkDefault` defaulting, so callers only need to set overrides.
    (mkAgentSkillsInstance "pi" {
      enable = true;

      sources = sharedSources;

      skills.enable = piSkillAllow;

      targets.pi = {
        enable = true;
        # dest left unset -> factory uses agentLib.defaultTargets.pi.dest
        # (= "$HOME/.pi/agent/skills"). The factory resolves this eagerly
        # because upstream's mkSyncScript embeds dest in a bash string and
        # does not unwrap lib.mkDefault overrides.
        structure = "symlink-tree";
      };

      excludePatterns = sharedExclude;
    })

    # Command Code instance
    (mkAgentSkillsInstance "cmd" {
      enable = true;

      sources = sharedSources;

      skills.enable = cmdSkillAllow;

      targets.cmd = {
        enable = true;
        dest = "$HOME/.commandcode/skills";
        structure = "symlink-tree";
      };

      excludePatterns = sharedExclude;
    })
  ];

  # =======================================================================
  # Instance 1: Hermes (full skill suite)
  # =======================================================================
  # Uses the upstream's `programs.agent-skills` HM module (imported in
  # flake.nix). Writes to `programs.agent-skills.*` and produces a
  # `home.activation.agent-skills` entry.
  programs.agent-skills = {
    enable = true;

    sources = sharedSources;

    skills.enable = hermesSkillAllow;

    targets.hermes = hermesTarget;

    excludePatterns = sharedExclude;
  };
}
