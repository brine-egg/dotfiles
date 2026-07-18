# AGENTS.md

Guidance for AI coding agents working in this repository.

## Repository overview

Nix flake managing system + Home Manager configs across three platforms:

- **Linux (non-NixOS, standalone HM):** `homeConfigurations."brine"` — x86_64-linux
- **macOS (nix-darwin + standalone HM):** `homeConfigurations."brine-darwin"` — aarch64-darwin
- **NixOS:** `nixosConfigurations.desktop` / `nixosConfigurations.laptop`

Current host is `north-fedora` (Fedora, non-NixOS) → uses `homeConfigurations."brine"`.

### Layout

```
flake.nix                    # flake inputs + output builders (mkHome, mkNixos, mkDarwin)
home/
  home.nix                   # shared Home Manager entry point
  config/shared/             # cross-platform HM modules (programs/, etc.)
  config/linux/              # Linux-only HM modules
  config/darwin/             # macOS-only HM modules
  packages/shared.nix        # cross-platform packages
  packages/linux.nix         # Linux-only packages
  packages/darwin.nix        # macOS-only packages
hosts/                       # per-host hardware/config (desktop, laptop, macbook)
nixos/                       # NixOS system config
darwin/                      # nix-darwin system config
```

## Build & deploy commands

### Home Manager (Linux standalone, this host)

```sh
# Apply changes — ALWAYS point at the flake and the correct configuration name
home-manager switch --flake .#brine
```

- The `.` means "this flake in the current directory."
- `#brine` selects `homeConfigurations."brine"`.
- **Do NOT run bare `home-manager switch`** without `--flake .#brine` — it will
  fall back to legacy non-flake mode and either error out or apply a stale config.

### Home Manager (macOS)

```sh
home-manager switch --flake .#brine-darwin
```

### NixOS

```sh
sudo nixos-rebuild switch --flake .#<hostname>
# e.g. sudo nixos-rebuild switch --flake .#desktop
```

### nix-darwin

```sh
darwin-rebuild switch --flake .#macbook
```

### Build without activating (sanity check)

```sh
nix build .#homeConfigurations.brine.activationPackage
```

## Git tracking before building

**Nix flakes ignore untracked files.** If you create a new `.nix` file and
reference it from another module (e.g. adding it to `imports`), the flake
evaluator will not see it until it is tracked by Git:

```sh
git add path/to/new-file.nix
home-manager switch --flake .#brine
```

Symptom of forgetting this: `error: getting status of ... No such file or directory`
even though the file exists on disk. Always `git add` new files before building.

## Hermes Agent specifics

Hermes is packaged via a vendored copy of numtide's `package.nix` at
`home/config/shared/programs/hermes-agent-package.nix`, spliced with
`extraPythonPackages` in `home/config/shared/programs/hermes.nix`.

### Adding a Python dependency to Hermes

1. Add the package to the `extraPythonPackages` list in `hermes.nix`.
2. If the package isn't in nixpkgs, create a Nix derivation
   (`home/config/shared/programs/hermes-<name>.nix`) using `buildPythonApplication`
   or `buildPythonPackage` + `fetchPypi` / `fetchFromGitHub`.
3. `git add` any new files.
4. Build: `home-manager switch --flake .#brine`.
5. Verify in the new Python env:
   ```sh
   # Find the new hermes binary's Python
   NEW_HERMES=$(readlink -f $(which hermes))
   HERMES_PY=$(grep -oP "HERMES_PYTHON='([^']+)'" "$NEW_HERMES" | sed "s/HERMES_PYTHON='//;s/'//")
   $HERMES_PY -c "import <package>; print('OK')"
   ```

### Hermes plugin as Nix derivation

To add a Hermes plugin (not just a Python dep):

1. Package the plugin library and the plugin itself as Nix derivations.
2. Add both to `extraPythonPackages` in `hermes.nix`.
3. Enable in `~/.hermes/config.yaml` under `plugins.enabled` and configure as
   needed (this file is outside the repo — it's the runtime config, not
   declarative).
4. `git add`, then `home-manager switch --flake .#brine`.

### Stale PATH after rebuild

After `home-manager switch`, the current shell session may still resolve the
**old** Hermes binary from a cached Nix store path. To pick up the new binary:

- Start a new shell, **or**
- Use the absolute path from the new generation:
  ```sh
  readlink -f $(which hermes)
  # Compare against the generation's store path
  ```

The Hermes TUI process itself must be restarted to load the new binary and
Python environment — it does not hot-reload.

## Conventions

- **Commits:** Use conventional commit format. Use `gc-hermes` instead of
  `git commit` — it appends the `Generated-By: Hermes Agent v<version>` trailer
  automatically. If unavailable, fall back to
  `hermes --version` → `git commit --trailer "Generated-By: Hermes Agent v<version>"`.
- **Branches:** Feature work goes on `feature/*` branches.
- **No `.gitignore`** in this repo — all files are intended to be tracked.
