{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {

  # Create symlinks for dotfiles
  home.file = {
    # Shell/CLI config
    ".zshrc".source = ./home/.zshrc;
    ".p10k.zsh".source = ./home/.p10k.zsh;
    ".miniplug.zsh".source = ./home/.miniplug.zsh;
    ".config/bat".source = ./config/bat;
    ".config/fastfetch".source = ./config/fastfetch;
    ".config/fsh".source = ./config/fsh;
    ".config/yazi".source = ./config/yazi;
    ".config/tmux/tmux.conf".source = ./config/tmux/tmux.conf;

    # Theme config
    # The icons and themes files do not seem to be registered by flatpaks if they are symlinked, so they need to be manually copied into a separate directory.
    # ".local/share/themes/catppuccin-mocha-lavender-standard+default".source = ./gnome/themes/catppuccin-mocha-lavender-standard+default;
    # ".local/share/themes/catppuccin-mocha-lavender-standard+default-hdpi".source = ./gnome/themes/catppuccin-mocha-lavender-standard+default-hdpi;
    # ".local/share/themes/catppuccin-mocha-lavender-standard+default-xhdpi".source = ./gnome/themes/catppuccin-mocha-lavender-standard+default-xhdpi;
    # ".local/share/icons/catppuccin-mocha-dark-cursors".source = ./gnome/icons/catppuccin-mocha-dark-cursors;
    # ".local/share/icons/papirus-folders".source = ./gnome/icons/papirus-folders;
    # ".config/gtk-4.0/assets".source = ./gnome/themes/catppuccin-mocha-lavender-standard+default/gtk-4.0/assets;
    # ".config/gtk-4.0/gtk-dark.css".source = ./gnome/themes/catppuccin-mocha-lavender-standard+default/gtk-4.0/gtk-dark.css;
    # ".config/gtk-4.0/gtk.css".source = ./gnome/themes/catppuccin-mocha-lavender-standard+default/gtk-4.0/gtk.css;
  };

  gtk = {
    enable = true;
    theme.package = pkgs.catppuccin-gtk;
    cursorTheme.package = pkgs.catppuccin-cursors;
    theme.name = "catppuccin-mocha-lavender-standard+default";
    cursorTheme.name = "catppuccin-mocha-dark-cursors";
  };

  # Manage MPV config
  # programs.mpv = {
  #   enable = true;
  #
  #   defaultProfiles = ["gpu-hq"];
  #
  #   bindings = {
  #     "Shift+Down" = "seek -15 exact";
  #     "Shift+Up" = "seek 15 exact";
  #     "Ctrl+i" = "cycle-values play-dir - +";
  #     "tab" = "script-binding uosc/toggle-ui"; # Toggle whether or not to always display uosc ui
  #     "i" = "script-binding toggle-seeker"; # Seek-to keybind
  #   };
  #
  #   config = { 
  #     osd-bar = "no";
  #     border = "no";
  #     sub-scale = 0.7;
  #     script-opts = "ytdl_hook-ytdl_path=yt-dlp";
  #     ytdl-format = "bestvideo[height<=?1080]+bestaudio/best";
  #     window-scale = 0.75;
  #     keepaspect-window = "yes";
  #     hr-seek = "always";
  #     screenshot-directory = "~/Pictures/mpv";
  #     screenshot-template = "%F-%n-%p";
  #    };
  #
  #   scripts = with pkgs; [
  #       mpvScripts.uosc
  #       mpvScripts.thumbfast
  #       mpvScripts.seekTo
  #   ];
  # };

}
