{ pkgs, inputs, lib, ... }:

# ============================================================================
# agent-skills: per-target skill selection
# ============================================================================
# Upstream `agent-skills-nix` (Kyure-A) builds ONE bundle from the union of
# `skills.enable` + `skills.enableAll` + `skills.explicit`, then syncs that
# same bundle to every enabled target. There is no per-target skill
# selection in upstream (confirmed by reading lib/default.nix and
# modules/common.nix).
#
# To get per-target selection without an upstream PR, we instantiate
# `programs.agent-skills` (Hermes) and a sibling `programs.agent-skills-pi`
# (Pi) as two separate module instances. The upstream HM module is imported
# once via flake.nix and is used as-is for Hermes. For Pi, we declare a
# local option and wire it up by calling the upstream's library functions
# directly (`inputs.agent-skills.lib.agent-skills`) -- this gives us a
# second bundle + a uniquely-named `home.activation.agent-skills-pi` entry
# that does not collide with the upstream's `home.activation.agent-skills`.
#
# Both instances declare the same `sources` (the upstream's `discoverCatalog`
# is cheap and idempotent; declaring it twice is required because the
# library functions take the sources as input per-bundle).
# ----------------------------------------------------------------------------

let
  # Re-import the upstream's lib with OUR inputs so source `input`
  # references (e.g. `sources.mattpocock-skills.input = "mattpocock-skills"`)
  # resolve against our flake's input registry, not the upstream's.
  # The upstream's flake output `inputs.agent-skills.lib.agent-skills` is
  # built with the upstream's own (empty) inputs, so it would throw
  # "source X refers to unknown input X" when called from our flake.
  agentLib = import (inputs.agent-skills + "/lib") {
    inherit lib;
    inputs = inputs;
  };

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

  # -- Pi target: use the upstream default --------------------------------
  # defaultTargets.pi.dest is "$HOME/.pi/agent/skills". We must set
  # `dest` explicitly here because the upstream's HM module's
  # `lib.mkDefault` defaulting (modules/common.nix: targets are filled
  # with `lib.mkDefault` from `defaultTargets`) is only wired up inside
  # the upstream's `programs.agent-skills` HM module -- not in our
  # local Pi instance. We set `dest` directly to the upstream's
  # default so this stays in lockstep with the upstream.
  piTarget = {
    enable = true;
    dest = agentLib.defaultTargets.pi.dest;
    structure = "symlink-tree";
  };

  # -- Pi-instance local module -------------------------------------------
  # The upstream HM module reads `config.programs.agent-skills.*` and sets
  # `home.activation.agent-skills`. We need a second, independent
  # instance for Pi, so we:
  #   1. Declare our own `programs.agent-skills-pi` option (free-form, so
  #      we don't have to re-declare every upstream option type).
  #   2. Drive a local `config` block that mirrors the upstream's logic
  #      but uses `programs.agent-skills-pi` and writes to
  #      `home.activation.agent-skills-pi` (unique name -> no collision
  #      with the upstream's `home.activation.agent-skills`).
  piModule = { config, ... }:
    let
      cfg = config.programs.agent-skills-pi;
      catalog = agentLib.discoverCatalog cfg.sources;
      allowlist = agentLib.allowlistFor {
        inherit catalog;
        sources = cfg.sources;
        enableAll = cfg.skills.enableAll or false;
        enable = cfg.skills.enable or [];
      };
      selection = agentLib.selectSkills {
        inherit catalog allowlist;
        skills = cfg.skills.explicit or {};
        sources = cfg.sources;
      };
      bundle = agentLib.mkBundle { inherit pkgs selection; };
      activeTargets = agentLib.targetsFor {
        targets = cfg.targets;
        system = pkgs.stdenv.hostPlatform.system;
      };
      syncScript = agentLib.mkSyncScript {
        inherit pkgs bundle;
        targets = activeTargets;
        system = pkgs.stdenv.hostPlatform.system;
        excludePatterns = cfg.excludePatterns;
      };
    in {
      options.programs.agent-skills-pi = lib.mkOption {
        type = lib.types.submodule {
          # Free-form-ish: we declare the same shape as the upstream's
          # `programs.agent-skills` option (sources, skills, targets,
          # excludePatterns, enable) so users can copy the same config
          # shape across the two instances. We don't reuse the upstream's
          # submodule types directly (they're not exported); we accept
          # the same structure as `attrsOf anything` and let the library
          # functions throw on malformed input. The hermes `programs.agent-skills`
          # instance still uses the upstream's strict types via the
          # imported HM module.
          freeformType = lib.types.attrsOf lib.types.anything;
          options = {
            enable = lib.mkEnableOption "Per-target Agent Skills management (Pi instance).";
          };
        };
        default = {};
        description = ''
          Second instance of agent-skills for the Pi target. Uses the
          upstream's library functions directly so per-target skill
          selection is possible (the upstream's `programs.agent-skills`
          HM module does not support per-target selection). Configure
          with the same `sources`/`skills`/`targets`/`excludePatterns`
          shape as the upstream's `programs.agent-skills`.
        '';
      };

      config = lib.mkIf cfg.enable {
        home.activation.agent-skills-pi =
          lib.mkIf (activeTargets != {})
            (lib.hm.dag.entryAfter [ "writeBoundary" ] syncScript);
      };
    };
in
{
  imports = [ piModule ];

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

  # =======================================================================
  # Instance 2: Pi (reduced, agent-agnostic subset)
  # =======================================================================
  # Uses our local `programs.agent-skills-pi` option (declared in
  # `piModule` above) which calls the upstream's library functions
  # directly. Produces a `home.activation.agent-skills-pi` entry (unique
  # name, so no collision with the Hermes activation).
  programs.agent-skills-pi = {
    enable = true;

    sources = sharedSources;

    skills.enable = piSkillAllow;

    targets.pi = piTarget;

    excludePatterns = sharedExclude;
  };
}
