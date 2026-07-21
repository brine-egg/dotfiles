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
  modules/shared/           # cross-platform HM modules (programs/, etc.)
  modules/linux/            # Linux-only HM modules
  modules/darwin/           # macOS-only HM modules
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

## Stale PATH after rebuild

After `home-manager switch`, the current shell session may still resolve
binaries from a cached Nix store path. To pick up the new generation:

- Start a new shell, **or**
- Compare the resolved path against the new generation:
  ```sh
  readlink -f $(which <binary>)
  ```

Long-running processes (daemons, TUI apps) must be restarted to load the new
binaries — they do not hot-reload.
