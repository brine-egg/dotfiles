# Disclaimer

This is a repo for syncing configuration files across my personal devices, there is no guarantee it will work properly on your device.
The configurations are also messy and break frequently.
*Use at your own risk.*

## Structure

This flake manages three kinds of configuration:

- **Home Manager** (standalone) — user-level dotfiles, shell, and programs.
- **NixOS** — Linux system configuration.
- **nix-darwin** — macOS system configuration.

```
.
├── flake.nix                 # all flake outputs
├── home/                     # Home Manager config
│   ├── home.nix
│   ├── config/               # shared, linux, darwin HM modules
│   └── packages/              # shared, linux, darwin packages
├── nixos/                    # shared NixOS system modules
│   ├── config/
│   └── packages/
├── darwin/                   # shared nix-darwin system modules
│   └── config/
└── hosts/                    # per-host config
    ├── desktop/               # NixOS host
    ├── laptop/                # NixOS host
    └── macbook/               # nix-darwin host
```

## Prerequisites

Install [Nix](https://nixos.org/) through the [Determinate Nix Installer](https://github.com/DeterminateSystems/nix-installer):

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

## Usage

### Non-NixOS Linux (standalone Home Manager)

```bash
git clone https://github.com/brine-egg/dotfiles $HOME/.dotfiles
home-manager switch --flake $HOME/.dotfiles#brine
```

### NixOS

Clone this repo to a directory of your choice, then:

```bash
sudo nixos-rebuild switch --flake .#desktop
```

Replace `desktop` with the hostname matching your machine in `hosts/`.

Before first use, replace the placeholder `hardware.nix` in your host directory with the actual hardware configuration from the NixOS installer (`/etc/nixos/hardware-configuration.nix`).

### macOS (nix-darwin + Home Manager)

macOS system config is managed by nix-darwin; home config is managed by standalone Home Manager. Both are applied separately:

```bash
# System-level (macOS defaults, nix settings, Spotlight trampolines)
darwin-rebuild switch --flake .#macbook

# User-level (shell, programs, dotfiles)
home-manager switch --flake .#brine-darwin
```

GUI apps installed via Nix packages are automatically wrapped as `.app` bundles and indexed by Spotlight, powered by [mac-app-util](https://github.com/hraban/mac-app-util). No Homebrew needed.

## Credits

This repo contains files from the [Catppuccin](https://github.com/catppuccin/catppuccin) project used for applying the colour theme across several programs.
The Nix flake based configurations uses the [nix-starter-configs repo](https://github.com/Misterio77/nix-starter-config) as a template.
