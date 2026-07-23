{ pkgs, inputs, lib, ... }@args:

# ============================================================================
# mkAgentSkillsInstance: a reusable factory for per-harness agent-skills
# ============================================================================
# Upstream `agent-skills-nix` (Kyure-A) builds ONE bundle per module instance
# and syncs it to every enabled target of that instance. It does NOT support
# per-target skill selection (the target submodule has no `skills` field --
# confirmed by reading upstream's lib/default.nix and modules/common.nix).
#
# Until upstream gains per-target skills, we work around this by instantiating
# one module instance per target (one bundle per target, each with its own
# skill allowlist). This file is the factory: callers invoke
# `mkAgentSkillsInstance "<name>" { sources; skills; targets; ... }` and get
# back a self-contained HM module that wires up `programs.agent-skills-<name>`
# + `home.activation.agent-skills-<name>`.
#
# Design notes:
#   - <name> appears in two places: the option root
#     `programs.agent-skills-<name>` and the activation entry name
#     `home.activation.agent-skills-<name>`. Names are kept short and
#     stable; rename = migration.
#   - The upstream's flake output `inputs.agent-skills.lib.agent-skills` is
#     built with the upstream's own (empty) inputs, so calling it from our
#     flake throws "source X refers to unknown input X". We sidestep that
#     by re-importing `inputs.agent-skills + "/lib"` with OUR flake's
#     `inputs`, which lets source `input = "..."` references resolve.
#   - This factory is local: do not expect it to be merged upstream. If
#     upstream lands per-target skill selection, this file should be
#     deleted and callers should switch to the upstream DSL.
# ----------------------------------------------------------------------------

let
  # Re-import the upstream's lib with OUR inputs so source `input`
  # references resolve against our flake's input registry. See header.
  agentLib = import (inputs.agent-skills + "/lib") {
    inherit lib;
    inputs = inputs;
  };
in
instanceName: instanceConfig:

assert builtins.isString instanceName;
assert (builtins.match "[A-Za-z_][A-Za-z0-9_-]*" instanceName != null) ||
  throw "agent-skills-instance: instanceName must match [A-Za-z_][A-Za-z0-9_-]* (got '${instanceName}')";

# The returned module. Note: `config` is bound by the HM module system at
# eval time; we don't need to declare it as a function arg explicitly.
{ config, ... }:

let
  # Computed option keys. `${...}` interpolation does not work inside
  # dotted attribute paths (e.g. `config.programs.foo-${bar}` is a parse
  # error), so we bind the strings first and reference them.
  optionKey = "agent-skills-${instanceName}";
  activationKey = "agent-skills-${instanceName}";

  cfg = config.programs.${optionKey};
  inherit (cfg) sources skills targets;

  # Per-target dest defaulting: the upstream's `lib.mkDefault`-based
  # defaulting only fires inside its own `programs.agent-skills` HM module.
  # We can't replicate that here because the upstream's `mkSyncScript`
  # interpolates `dest` directly into a bash string and does not unwrap
  # `lib.mkDefault` overrides (it would coerce a set to a string and fail).
  # So we resolve the default eagerly: if the caller didn't set `dest` and
  # the target name matches an upstream `defaultTargets` entry, fall back
  # to that. Callers wanting a non-default `dest` must set it explicitly.
  targetsWithDefaults = lib.mapAttrs (targetName: t:
    if t ? dest then t
    else if agentLib.defaultTargets ? ${targetName}
    then t // { dest = agentLib.defaultTargets.${targetName}.dest; }
    else t // {
      dest = throw "agent-skills-instance: target '${targetName}' has no `dest` and is not an upstream default target (known defaults: ${lib.concatStringsSep ", " (builtins.attrNames agentLib.defaultTargets)})";
    }
  ) targets;

  catalog = agentLib.discoverCatalog sources;
  allowlist = agentLib.allowlistFor {
    inherit catalog sources;
    enableAll = skills.enableAll or false;
    enable = skills.enable or [];
  };
  selection = agentLib.selectSkills {
    inherit catalog allowlist sources;
    skills = skills.explicit or {};
  };
  bundle = agentLib.mkBundle { inherit pkgs selection; };

  activeTargets = agentLib.targetsFor {
    targets = targetsWithDefaults;
    system = pkgs.stdenv.hostPlatform.system;
  };

  syncScript = agentLib.mkSyncScript {
    inherit pkgs bundle;
    targets = activeTargets;
    system = pkgs.stdenv.hostPlatform.system;
    excludePatterns = cfg.excludePatterns;
  };

  # Freeform type for sources/skills/targets because the upstream submodule
  # types are not exported. The library functions (`discoverCatalog`,
  # `allowlistFor`, `selectSkills`, `mkBundle`, `targetsFor`) throw on
  # malformed input, so we don't lose error checking -- we just don't get
  # NixOS-module-time type errors. This is the same trade-off the
  # `programs.agent-skills-pi` freeform block made in the previous design.
  instanceSubmodule = lib.types.submodule {
    freeformType = lib.types.attrsOf lib.types.anything;
    options = {
      enable = lib.mkEnableOption "Per-harness Agent Skills management (instance '${instanceName}').";
    };
  };
in
{
  options.programs.${optionKey} = lib.mkOption {
    type = instanceSubmodule;
    default = {};
    description = ''
      Configuration for agent-skills instance '${instanceName}'.
      Mirrors the upstream `programs.agent-skills` shape (sources, skills,
      targets, excludePatterns) so that when upstream gains per-target
      skill selection, callers can migrate by moving the `skills.<id>`
      into `targets.<name>.skills.<id>` and dropping this wrapper.
      For each target, if `dest` is unset and the target name matches an
      upstream `defaultTargets` entry (e.g. `pi`, `claude`, `codex`), the
      upstream default is used. Set `dest` explicitly to override.
    '';
  };

  config = lib.mkMerge [
    # Bind the user-provided `instanceConfig` to the declared option. Without
    # this, `programs.${optionKey}` would default to `{}` and the bundle would
    # be empty. The merge is unconditional so the option is always reachable
    # for `cfg = config.programs.${optionKey}` reads in the activation block
    # below.
    { programs.${optionKey} = instanceConfig; }

    # Activation entry. Gated by `cfg.enable` so disabled instances produce
    # no home.activation entry at all.
    (lib.mkIf cfg.enable {
      home.activation.${activationKey} =
        lib.mkIf (activeTargets != {})
          (lib.hm.dag.entryAfter [ "writeBoundary" ] syncScript);
    })
  ];
}