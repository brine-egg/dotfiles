{
  pkgs,
  ...
}: {
  # Raw dotfiles symlinked into $HOME
  home.file = {
    ".zshrc".source = ./home/.zshrc;
    ".p10k.zsh".source = ./home/.p10k.zsh;
    ".miniplug.zsh".source = ./home/.miniplug.zsh;
    ".config/fastfetch".source = ./config/fastfetch;
    ".config/fsh".source = ./config/fsh;
  };

  # Kitty terminal emulator
  programs.kitty = {
    enable = true;
    themeFile = "Catppuccin-Mocha";
    font = {
      name = "RobotoMono NFM";
      size = 12;
    };
    settings = {
      repaint_delay = 5;
      scrollback_lines = 5000;
      tab_bar_edge = "top";
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";
    };
  };

  # Catppuccin theme for supported programs
  catppuccin = {
    flavor = "mocha";
    bat.enable = true;
    btop.enable = true;
    yazi.enable = true;
  };

  # Bat (syntax-highlighted cat)
  programs.bat.enable = true;

  # Yazi file manager
  programs.yazi = {
    enable = true;
    plugins = {
      archivemount = pkgs.fetchFromGitHub {
        owner = "brine-egg";
        repo = "archivemount.yazi";
        rev = "8e09c26552e4dec4ddab274cc603d79982ec722b";
        sha256 = "sha256-uHZLITKmmGsCsCgIKRLiuI/bRMTtcVU5v3f38HPhqTs=";
      };
    };
    keymap = {
      manager.prepend_keymap = [
        {
          on = [ "M" ];
          run = "plugin archivemount --args=mount";
          desc = "Mount selected archive";
        }
        {
          on = [ "U" ];
          run = "plugin archivemount --args=unmount";
          desc = "Unmount and save changes to original archive";
        }
      ];
    };
  };

  # Btop system monitor
  programs.btop = {
    enable = true;
    settings = {
      vim_keys = true;
      proc_tree = true;
    };
  };

  # Tmux terminal multiplexer
  programs.tmux = {
    enable = true;
    mouse = true;
    sensibleOnTop = true;
    disableConfirmationPrompt = true;
    prefix = "C-Space";
    keyMode = "vi";
    escapeTime = 0;
    baseIndex = 1;
    historyLimit = 5000;
    terminal = "xterm-256color";
    plugins = [
      {
        plugin = pkgs.tmuxPlugins.catppuccin;
        extraConfig = ''
          set -g @catppuccin_status_left_separator "█"
          set -g @catppuccin_status_right_separator "█"
          set -g @catppuccin_window_default_background "#{thm_black}"
          set -g @catppuccin_window_current_background "#{thm_gray}"
          set -g @catppuccin_window_number_position "left"
          set -g @catppuccin_window_status_enable "yes"
          set -g @catppuccin_window_status_icon_enable "no"
        '';
      }
      pkgs.tmuxPlugins.vim-tmux-navigator
      pkgs.tmuxPlugins.jump
    ];

    extraConfig = ''
      bind "v" split-window -hc "#{pane_current_path}"
      bind "h" split-window -vc "#{pane_current_path}"

      bind -n "M-h" resize-pane -L 5
      bind -n "M-j" resize-pane -D 5
      bind -n "M-k" resize-pane -U 5
      bind -n "M-l" resize-pane -R 5

      bind -r -T prefix "M-h" resize-pane -L 1
      bind -r -T prefix "M-j" resize-pane -D 1
      bind -r -T prefix "M-k" resize-pane -U 1
      bind -r -T prefix "M-l" resize-pane -R 1

      bind "e" kill-window

      set-option -sa terminal-overrides ",xterm*:Tc"
    '';
  };

  # GTK theme, icons, fonts, and cursors
  gtk = {
    enable = true;
    font = {
      name = "Clear Sans Medium, Medium 12";
      package = pkgs.texlivePackages.clearsans;
    };
    theme = {
      name = "catppuccin-mocha-lavender-standard+default";
      package = pkgs.catppuccin-gtk;
    };
    iconTheme = {
      name = "Papirus";
      package = pkgs.catppuccin-papirus-folders.override {
        flavor = "mocha";
        accent = "lavender";
      };
    };
    cursorTheme = {
      name = "catppuccin-mocha-dark-cursors";
      package = pkgs.catppuccin-cursors;
    };
  };
}
