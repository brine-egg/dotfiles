{
  pkgs,
  lib,
  ...
}:
{
  # Zsh shell configuration
  programs.zsh = {
    enable = true;

    # Completion system
    enableCompletion = true;
    completionInit = ''
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
      setopt NO_CASE_GLOB
      setopt MENU_COMPLETE
    '';

    # Persistent history
    history = {
      path = "$HOME/.zsh_history";
      size = 2000;
      save = 2000;
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
      append = true;
    };

    # History-related setopts (plus append/share/incappend)
    setOptions = [
      "APPEND_HISTORY"
      "SHARE_HISTORY"
      "INC_APPEND_HISTORY"
      "NO_CASE_GLOB"
      "MENU_COMPLETE"
      "HIST_IGNORE_DUPS"
    ];

    # Aliases
    shellAliases = {
      ls = "lsd";
    };

    # Must run before any plugin sourcing (p10k instant prompt + stty)
    initExtraFirst = ''
      # Enable Powerlevel10k instant prompt.
      if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
        source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
      fi

      # Disable XON/XOFF flow control (frees C-s/C-q)
      if [[ -t 0 ]]; then
        stty -ixon
      fi
    '';

    # Source externally written env variables in .zshenv
    envExtra = ''
      source "$HOME/.env"
    '';

    # Runs before plugin sourcing
    initExtra = ''
      # Powerlevel10k theme + p10k config
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

      # Preconfigure Zsh Vi Mode (consumed by zsh-vi-mode plugin)
      function zvm_config() {
        ZVM_VI_HIGHLIGHT_BACKGROUND=#585b70
        ZVM_VI_HIGHLIGHT_FOREGROUND=#f5c2e7
        ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLINKING_BLOCK
        ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BLINKING_BEAM
        ZVM_VISUAL_MODE_CURSOR=$ZVM_CURSOR_BLINKING_BLOCK
        ZVM_VISUAL_LINE_MODE_CURSOR=$ZVM_CURSOR_BLINKING_BLOCK
        ZVM_INIT_MODE=sourcing
      }

      # Catppuccin theme for Fast Syntax Highlighting
      fast-theme XDG:catppuccin-mocha -q

      # Custom variables
      export NVIM="$HOME/.config/nvim"
      export SHADA="$HOME/.local/state/nvim/shada"

      ${lib.optionalString pkgs.stdenv.isLinux ''
        # Sourced by the Nix installer on non-NixOS Linux
        if [ -e /home/brine/.nix-profile/etc/profile.d/nix.sh ]; then
          . /home/brine/.nix-profile/etc/profile.d/nix.sh
        fi
      ''}
    '';

    # Fish-like autosuggestions (sourced by Home Manager)
    autosuggestion.enable = true;

    # Plugins without dedicated HM submodules.
    # NOTE: fast-syntax-highlighting (the zdharma-continuum fork) is sourced
    # here as a plugin rather than via `programs.zsh.syntaxHighlighting`,
    # because the HM submodule uses the standard `zsh-syntax-highlighting`
    # package which lacks the `fast-theme` command used below in initExtra.
    # Plugins are sourced before initExtra, so `fast-theme` is available.
    plugins = [
      {
        name = "fast-syntax-highlighting";
        src = pkgs.zsh-fast-syntax-highlighting;
        file = "share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh";
      }
      {
        name = "zsh-vi-mode";
        src = pkgs.zsh-vi-mode;
        file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
      }
      {
        name = "yazi-zoxide-zsh";
        src = pkgs.fetchFromGitHub {
          owner = "fdw";
          repo = "yazi-zoxide-zsh";
          rev = "51f910c6b6ec6f106905bd7487e3ee7539dfdd87";
          sha256 = "sha256-truqprtbsy0Don9UX54AOZeD/2x8hmH+583jZkG8FIo=";
        };
        file = "yazi-zoxide-zsh.plugin.zsh";
      }
    ];
  };

  # zsh-completions: ships only share/zsh/site-functions (no plugin file).
  # Adding to home.packages lets HM's completion system pick it up via fpath.
  home.packages = [ pkgs.zsh-completions ];

  # Editor + session variables
  home.sessionVariables = {
    EDITOR = "nvim";
    SUDO_EDITOR = "nvim";
  };

  # We use fast-syntax-highlighting (sourced as a zsh plugin) with its own
  # catppuccin theme via `fast-theme XDG:catppuccin-mocha`, so disable the
  # catppuccin module's integration for the standard zsh-syntax-highlighting
  # (which would otherwise be sourced as a no-op).
  catppuccin.zsh-syntax-highlighting.enable = lib.mkForce false;
}
